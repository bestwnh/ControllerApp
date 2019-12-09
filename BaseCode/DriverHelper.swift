//
//  DriverHelper.swift
//  ControllerApp
//
//  Created by Galvin on 2019/10/24.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation


struct DriverHelper {
    static let driverName = "360Controller.kext"
    static let applicationID = "com.mice.driver.Xbox360Controller.devices" as CFString

    static var rootDirectory: URL? {
        guard let dir = FileManager.default.urls(for: .libraryDirectory, in: .localDomainMask).first else {
            return nil
        }
        
        return dir.appendingPathComponent("Extensions")
    }
    
    static func infoPlistPath(of driver: String = driverName) -> URL? {
        return rootDirectory?
            .appendingPathComponent(driver)
            .appendingPathComponent("Contents")
            .appendingPathComponent("Info.plist")
    }
    
    static func readDriverConfig(_ driver: String = driverName) -> [String: Any] {
        guard let file = infoPlistPath(of: driver) else { return [:] }
        do {
            let data = try Data(contentsOf: file)
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
//            print(plist)
            return plist as? [String: Any] ?? [:]
        } catch {
            print("load file: \(file) failed with error: \(error)")
            return [:]
        }
    }
    
    static func writeDriverConfig(driver: String = driverName, plist: Any) {
        guard let file = infoPlistPath(of: driver) else { return }
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            let plistAttributes = try FileManager.default.attributesOfFileSystem(forPath: file.path)
            try data.write(to: file)
            try FileManager.default.setAttributes(plistAttributes, ofItemAtPath: file.path)
        } catch {
            print("write file: \(file) failed with error: \(error)")
        }
    }
    
    static func getTypes() -> [String] {
        let plist = readDriverConfig()
        guard let types = plist["IOKitPersonalities"] as? [String: Any] else { return [] }
        return types.compactMap({ (key, value) in
            guard let device = value as? [String: Any] else { return nil}
            guard (device["IOClass"] as? String) == "Xbox360Peripheral" else { return nil }
            let idVendor = device["idVendor"] as? Int ?? 0
            let idProduct = device["idProduct"] as? Int ?? 0
            return "\(key.utf8),\(idVendor),\(idProduct)"
        })
    }
    
    static func getDeviceList() -> [Device] {
        let classesToMatch = IOServiceMatching("IOHIDDevice") as NSMutableDictionary
        var result: kern_return_t = KERN_FAILURE
        var portIterator: io_iterator_t = 0
        
        result = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &portIterator)
        if result == KERN_SUCCESS {
            let deivices = getHIDDevices(iterator: portIterator)
            return deivices
        }
        
        return []
    }
    
    private static func getHIDDevices(iterator: io_iterator_t) -> [Device] {
        var newDevices:[Device] = []
        while case let rawDevice = IOIteratorNext(iterator), rawDevice != 0 {
            
            if let device = Device(rawDevice: rawDevice) {
                newDevices.append(device)
            }
            IOObjectRelease(rawDevice)
        }
        IOObjectRelease(iterator)

        return newDevices
    }
    
    static func loadDeviceConfiguration(rawDevice: io_object_t) -> DeviceConfiguration {
        _ = CFPreferencesSynchronize(applicationID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        let value = CFPreferencesCopyValue(rawDevice.serialNumber, applicationID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        return DeviceConfiguration(value as? [String: Any])
    }
    
    static func saveDeviceConfiguration(rawDevice: io_object_t, configuration: DeviceConfiguration) {
        IORegistryEntrySetCFProperties(rawDevice, configuration.toDict() as CFTypeRef)
        CFPreferencesSetValue(
            rawDevice.serialNumber,
            configuration.toDict() as CFPropertyList,
            applicationID,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost)
        _ = CFPreferencesSynchronize(applicationID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
    }
}


