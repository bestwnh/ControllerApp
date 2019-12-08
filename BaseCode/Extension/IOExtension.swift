//
//  IOExtension.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/8.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

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
