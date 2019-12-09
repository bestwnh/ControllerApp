//
//  IOExtension.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/8.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

//from IOHIDLibObsolete.h
let kIOHIDDeviceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                  0xFA, 0x12, 0xFA, 0x38, 0x6F, 0x1A, 0x11, 0xD4,
                                                                  0xBA, 0x0C, 0x00, 0x05, 0x02, 0x8F, 0x18, 0xD5)
let kIOHIDDeviceInterfaceID122 = CFUUIDGetConstantUUIDWithBytes(nil,
                                                             0xb7, 0xa, 0xbf, 0x31, 0x16, 0xd5, 0x11, 0xd7,
                                                             0xab, 0x35, 0x0, 0x3, 0x93, 0x99, 0x2e, 0x38)

//from IOCFPlugin.h
let kIOCFPlugInInterfaceID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                            0xC2, 0x44, 0xE8, 0x58, 0x10, 0x9C, 0x11, 0xD4,
                                                            0x91, 0xD4, 0x00, 0x50, 0xE4, 0xC6, 0x42, 0x6F)

extension io_object_t {
    var parent: io_object_t {
        var parent: io_object_t = 0
        IORegistryEntryGetParentEntry(self, kIOServicePlane, &parent)
        return parent
    }
    var controllerType: Device.ControlType? {
        var serviceProperties: Unmanaged<CFMutableDictionary>?
        if IORegistryEntryCreateCFProperties(self, &serviceProperties, kCFAllocatorDefault, 0) == KERN_SUCCESS {
            let properties = serviceProperties?.takeRetainedValue()
            if let dict = properties as? [String: Any],
                let deviceData = dict["DeviceData"] as? [String: Any],
                let controllerType = deviceData["ControllerType"] as? NSNumber {
                return Device.ControlType(rawValue: controllerType.intValue)
            }
        }
        
        return nil
    }
    var isWired: Bool {
        return IOObjectConformsTo(parent, "Xbox360Peripheral") != 0 || IOObjectConformsTo(self, "Xbox360ControllerClass") != 0
    }
    var isWireless: Bool {
        return IOObjectConformsTo(self, "WirelessHIDDevice") != 0 || IOObjectConformsTo(self, "WirelessOneController") != 0
    }
    var serialNumber: CFString {
        if let value = IORegistryEntrySearchCFProperty(
            self,
            kIOServicePlane,
            "USB Serial Number" as CFString,
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)) {
            return value as! CFString
        } else if let value = IORegistryEntrySearchCFProperty(
            self,
            kIOServicePlane,
            "SerialNumber" as CFString,
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)) {
            return value as! CFString
        }
        return "" as CFString
    }
    
}
