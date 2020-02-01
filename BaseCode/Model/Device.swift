//
//  Device.swift
//  ControllerApp
//
//  Created by Galvin on 2019/10/28.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation
import IOKit.usb
import IOKit.hid
import ForceFeedback

class Device {
    enum ControlType: Int, Codable {
        case Xbox360 = 0
        case XboxOriginal
        case XboxOne
        case XboxOnePretend360
        case Xbox360Pretend360
        
        var validRumbleTypes: [DeviceConfiguration.RumbleType] {
            switch self {
            case .XboxOne, .XboxOnePretend360:
                return [.default, .none, .triggersOnly, .both]
            default:
                return [.default, .none]
            }
        }
    }
    
    let displayName: String
    let type: ControlType
    private(set) var rawDevice: io_object_t
    private(set) var ffDevice: FFDeviceObjectReference?
    var hidDevice: IOHIDDeviceInterface122?
    var hidDevicePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDDeviceInterface122>?>?
    
    var configuration: DeviceConfiguration {
        didSet {
            DriverHelper.saveDeviceConfiguration(rawDevice: rawDevice, configuration: configuration)
        }
    }
    
    deinit {
        if rawDevice != 0 {
            IOObjectRelease(rawDevice)
        }
        if hidDevicePtrPtr != nil {
            _ = hidDevice!.Release(hidDevicePtrPtr)
            hidDevicePtrPtr = nil
            hidDevice = nil
        }
        if ffDevice != nil {
            FFReleaseDevice(ffDevice)
        }
    }
    
    init?(rawDevice: io_object_t) {
        
        if !rawDevice.isWired && !rawDevice.isWireless {
            return nil
        }
        
        self.rawDevice = rawDevice
        #warning("Can't get Force Feedback device, https://github.com/360Controller/360Controller/issues/978")
        FFCreateDevice(rawDevice, &ffDevice)
        
        displayName = {
            var serviceProperties: Unmanaged<CFMutableDictionary>?
            
            guard IORegistryEntryCreateCFProperties(rawDevice, &serviceProperties, kCFAllocatorDefault, 0) == KERN_SUCCESS else { return "" }
            
            let properties = serviceProperties?.takeRetainedValue()
            
            guard let dict = properties as? [String: Any] else { return "" }
            
            return (dict["Product"] as? String) ?? (dict["USB Product Name"] as? String) ?? ""
            
        }()
        
        type = {
            if let type = rawDevice.controllerType {
                return type
            }
            
            let parent = rawDevice.parent
            if parent != 0, let type = parent.controllerType {
                return type
            }
            
            print("⚠️couldn't find ControllerType")
            return .Xbox360
        }()
        
        let _hidDevicePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDDeviceInterface122>?>? = {
            var deviceInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDDeviceInterface122>?>?
            var plugInInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?
            var source: Int32 = 0
            var ioReturn: IOReturn = 0
            ioReturn = IOCreatePlugInInterfaceForService(rawDevice,
                                                         kIOHIDDeviceUserClientTypeID,
                                                         kIOCFPlugInInterfaceID,
                                                         &plugInInterfacePtrPtr,
                                                         &source)
            guard ioReturn == kIOReturnSuccess else { return nil }
            
            guard let plugInInterface = plugInInterfacePtrPtr?.pointee?.pointee else {
                print("Unable to get Plug-In Interface")
                return nil
            }
            
            // use plug in interface to get a device interface
            ioReturn = withUnsafeMutablePointer(to: &deviceInterfacePtrPtr) {
                $0.withMemoryRebound(to: Optional<LPVOID>.self, capacity: 1) {
                    plugInInterface.QueryInterface(
                        plugInInterfacePtrPtr,
                        CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID122),
                        $0)
                }
            }
            
            // dereference pointer for the device interface
            guard ioReturn == kIOReturnSuccess else {
                return nil
            }
                        
            return deviceInterfacePtrPtr
        }()
        
        guard let hidDevicePtrPtr = _hidDevicePtrPtr,
            let hidDevice = hidDevicePtrPtr.pointee?.pointee else {
            print("Unable to get Device Interface")
            return nil
        }
        self.hidDevice = hidDevice
        self.hidDevicePtrPtr = hidDevicePtrPtr
        
        // load configurations
        configuration = DriverHelper.loadDeviceConfiguration(rawDevice: rawDevice)
        // make sure configuration active in driver
        DriverHelper.saveDeviceConfiguration(rawDevice: rawDevice, configuration: configuration)
    }
    
}

extension Device: Hashable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawDevice)
    }
}

