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

enum ControllerAxis: Int {
    case leftStickX = 0
    case leftStickY
    case rightStickX
    case rightStickY
    case leftTrigger
    case rightTrigger
    
    var title: String {
        switch self {
        case .leftStickX:
            return "leftStickX"
        case .leftStickY:
            return "leftStickY"
        case .rightStickX:
            return "rightStickX"
        case .rightStickY:
            return "rightStickY"
        case .leftTrigger:
            return "leftTrigger"
        case .rightTrigger:
            return "rightTrigger"
        }
    }
}

enum ControllerButton: Int {
    case A = 0
    case B
    case X
    case Y
    case LB
    case RB
    case LeftStick
    case RightStick
    case start
    case back
    case home
    case up
    case down
    case left
    case right
    
    var title: String {
        switch self {
        case .A:
            return "A"
        case .B:
            return "B"
        case .X:
            return "X"
        case .Y:
            return "Y"
        case .LB:
            return "LB"
        case .RB:
            return "RB"
        case .LeftStick:
            return "LeftStick"
        case .RightStick:
            return "RightStick"
        case .start:
            return "start"
        case .back:
            return "back"
        case .home:
            return "home"
        case .up:
            return "up"
        case .down:
            return "down"
        case .left:
            return "left"
        case .right:
            return "right"
        }
    }
}

class Device {
    enum ControlType: Int {
        case Xbox360 = 0
        case XboxOriginal
        case XboxOne
        case XboxOnePretend360
        case Xbox360Pretend360
    }
    let displayName: String
    let type: ControlType
    let isWireless: Bool
    let rawDevice: io_object_t
    private(set) var ffDevice: FFDeviceObjectReference?
    var hidDevice: IOHIDDeviceInterface122
    var hidDevicePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDDeviceInterface122>?>?
    
    var axis: [IOHIDElementCookie] = Array(repeating: 0, count: 6)
    var buttons: [IOHIDElementCookie] = Array(repeating: 0, count: 15)
    var hidQueue: IOHIDQueueInterface?
    var hidQueuePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDQueueInterface>?>?

    init?(rawDevice: io_object_t) {
        let parent = IOUSBHelper.getParent(device: rawDevice)
        let isDeviceWired = IOObjectConformsTo(parent, "Xbox360Peripheral") != 0 || IOObjectConformsTo(rawDevice, "Xbox360ControllerClass") != 0
        let isDeviceWireless = IOObjectConformsTo(rawDevice, "WirelessHIDDevice") != 0 || IOObjectConformsTo(rawDevice, "WirelessOneController") != 0
        isWireless = isDeviceWireless
        
        if !isDeviceWired && !isDeviceWireless {
            return nil
        }
        
        self.rawDevice = rawDevice
        FFCreateDevice(rawDevice, &ffDevice)
        
        displayName = {
            var serviceProperties: Unmanaged<CFMutableDictionary>?
            
            guard IORegistryEntryCreateCFProperties(rawDevice, &serviceProperties, kCFAllocatorDefault, 0) == KERN_SUCCESS else { return "" }
            
            let properties = serviceProperties?.takeRetainedValue()
            
            guard let dict = properties as? [String: Any] else { return "" }
            
            return (dict["Product"] as? String) ?? (dict["USB Product Name"] as? String) ?? ""
            
        }()
        
        type = {
            func getControllerType(from device: io_object_t) -> ControlType? {
                var serviceProperties: Unmanaged<CFMutableDictionary>?
                if IORegistryEntryCreateCFProperties(rawDevice, &serviceProperties, kCFAllocatorDefault, 0) == KERN_SUCCESS {
                    let properties = serviceProperties?.takeRetainedValue()
                    if let dict = properties as? [String: Any],
                        let deviceData = dict["DeviceData"] as? [String: Any],
                        let controllerType = deviceData["ControllerType"] as? NSNumber {
                        return ControlType(rawValue: controllerType.intValue)
                    }
                }
                
                return nil
            }
            if let type = getControllerType(from: rawDevice) {
                return type
            }
            
            let parent = IOUSBHelper.getParent(device: rawDevice)
            if parent != 0, let type = getControllerType(from: parent) {
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
    }
}

extension Device {
    func start() {
        var devicePathCString:[CChar] = [CChar](repeating: 0, count: 128)
        IORegistryEntryGetPath(rawDevice, "IOService", &devicePathCString)
        var elements: Unmanaged<CFArray>?
        guard hidDevice.copyMatchingElements(hidDevicePtrPtr, nil, &elements) == kIOReturnSuccess,
            let elementList = elements?.takeRetainedValue() as? [[String: Any]] else {
            print("Can't get elements list")
            return
        }
        
        
        for element in elementList {
            
            // Get cookie
            guard let cookie: IOHIDElementCookie = (element[kIOHIDElementCookieKey] as? NSNumber)?.uint32Value else {
                continue
            }
            
            // Get usage
            guard let usage: Int = (element[kIOHIDElementUsageKey] as? NSNumber)?.intValue else {
                continue
            }
            
            // Get usage page
            guard let usagePage: Int = (element[kIOHIDElementUsagePageKey] as? NSNumber)?.intValue else {
                continue
            }
            // Match up items
            switch (usagePage, usage) {
            case (0x01, 0x35): // Right trigger
                axis[5] = cookie
            case (0x01, 0x32): // Left trigger
                axis[4] = cookie
            case (0x01, 0x34): // Right stick X
                axis[3] = cookie
            case (0x01, 0x33): // Right stick X
                axis[2] = cookie
            case (0x01, 0x31): // Left stick Y
                axis[1] = cookie
            case (0x01, 0x30): // Left stick X
                axis[0] = cookie
            case (0x09, 1...15):
                buttons[usage - 1] = cookie
            default: break
            }
        }
        
        print(axis)
        print(buttons)
        
        // Start queue
        guard hidDevice.open(hidDevicePtrPtr, 0) == kIOReturnSuccess else {
            print("Can't open device")
            return
        }
        
        hidQueuePtrPtr = hidDevice.allocQueue(hidDevicePtrPtr)
        hidQueue = hidQueuePtrPtr?.pointee?.pointee
        guard let hidQueue = hidQueue else {
            print("Unable to create the queue")
            return
        }
        
        guard hidQueue.create(hidQueuePtrPtr, 0, 32) == kIOReturnSuccess else {
            print("Unable to create the queue")
            return
        }
        
        // Create event source
        var eventSource: Unmanaged<CFRunLoopSource>?
        guard hidQueue.createAsyncEventSource(hidQueuePtrPtr, &eventSource) == kIOReturnSuccess else {
            print("Unable to create async event source")
            return
        }
        
        let eventCallback: IOHIDCallbackFunction = {
            (target, result, refcon, sender) in
            let device = Unmanaged<Device>
            .fromOpaque(target!).takeUnretainedValue()
            guard result == kIOReturnSuccess else { return }
            device.eventQueueFired()
        }
        // Set callback
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        guard hidQueue.setEventCallout(hidQueuePtrPtr, eventCallback, selfPtr, nil) == kIOReturnSuccess else {
            print("Unable to set event callback")
            return
        }
        
        // Add to runloop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), eventSource?.takeRetainedValue(), CFRunLoopMode.commonModes)
        
        // Add some elements
        axis.forEach{ _ = hidQueue.addElement(hidQueuePtrPtr, $0, 0) }
        buttons.forEach{ _ = hidQueue.addElement(hidQueuePtrPtr, $0, 0) }

        // Start
        guard hidQueue.start(hidQueuePtrPtr) == kIOReturnSuccess else {
            print("Unable to start queue")
            return
        }
        
        print("started.")
    }
    
    
    func eventQueueFired() {
        print("event fired!!")
        guard let hidQueue = hidQueue else { return }
        var event: IOHIDEventStruct = IOHIDEventStruct()
        var result: IOReturn = kIOReturnSuccess
        mainLoop: while result == kIOReturnSuccess {
            result = hidQueue.getNextEvent(hidQueuePtrPtr, &event, event.timestamp, 0)
            
            guard result == kIOReturnSuccess else { continue }
            
            // Check axis
            for (index, cookie) in axis.enumerated() {
                if event.elementCookie == cookie {
                    
                    print("axis changed: \(ControllerAxis(rawValue: index)?.title ?? "") value: \(event.value)")
                    continue mainLoop
                }
            }
            
            // Check buttons
            for (index, cookie) in buttons.enumerated() {
                if event.elementCookie == cookie {
                    print("buttons change: \(ControllerButton(rawValue: index)?.title ?? "") value: \(event.value)")
                    continue mainLoop
                }
            }
        }
    }
}
