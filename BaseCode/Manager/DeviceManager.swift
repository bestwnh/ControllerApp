//
//  DeviceManager.swift
//  ControllerApp
//
//  Created by Galvin on 2019/11/28.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

final class DeviceManager {
    static let shared = DeviceManager()
    private init() {}

    private(set) var deviceList: [Device] = [] {
        didSet {
            NotificationObserver.post(target: NotificationObserver.Target.deviceListChanged)
        }
    }
    private(set) var currentDevice: Device? {
        didSet {
            guard oldValue != currentDevice else { return }
            if let device = oldValue {
                stopMonitor(device: device)
                rumble?.stopRumbleMotor()
                rumble = nil
            }
            if let device = currentDevice {
                startMonitor(device: device)
                rumble = DeviceRumble()
                rumble?.startRumbleMotor(ffDevice: device.ffDevice)
            }

            NotificationObserver.post(target: NotificationObserver.Target.currentDeviceChanged, param: nil)
        }
    }
    
    private var usbDetector: IOUSBDetector?
    
    private var deviceEvents: [DeviceEvent] = []
    private var hidQueue: IOHIDQueueInterface?
    private var hidQueuePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDQueueInterface>?>?
    
    private var rumble: DeviceRumble?
    private var prevDeviceConfiguration: DeviceConfiguration?
    
    deinit {
        usbDetector?.stopDetection()
        currentDevice = nil
    }
}

extension DeviceManager {
    func selectedDevice(atIndex index: Int) {
        currentDevice = deviceList[safe: index]
    }
    func startMonitorDeviceChange() {
        guard usbDetector == nil else { return }
        usbDetector = IOUSBDetector()
        
        usbDetector?.callbackQueue = DispatchQueue.global()
        usbDetector?.callback = { [weak self] (detector, event, service) in
            guard let self = self else { return }
            // wait a second for get device ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateDeviceList()
            }
        }
        _ = usbDetector?.startDetection()
    }
    func deviceEvent(mode: DeviceEvent.Mode) -> DeviceEvent? {
        return deviceEvents.first(where: { $0.mode == mode })
    }
    func updateDeviceList() {
        deviceList = DriverHelper.getDeviceList()
        if let currentDevice = currentDevice, !deviceList.contains(currentDevice) {
            self.currentDevice = nil
        }
        
        if self.currentDevice == nil {
            self.currentDevice = deviceList.first
        }
        
    }
}

private extension DeviceManager {
    
    func startMonitor(device: Device) {
        guard let hidDevice = device.hidDevice, let hidDevicePtrPtr = device.hidDevicePtrPtr else { return }
        
        var elements: Unmanaged<CFArray>?
        guard hidDevice.copyMatchingElements(hidDevicePtrPtr, nil, &elements) == kIOReturnSuccess,
            let elementList = elements?.takeRetainedValue() as? [[String: Any]] else {
            print("Can't get elements list")
            return
        }
        
        deviceEvents = elementList.compactMap(DeviceEvent.init(element:))
        
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
            guard let target = target else { return }
            let deviceManager = Unmanaged<DeviceManager>
            .fromOpaque(target).takeUnretainedValue()
            guard result == kIOReturnSuccess else { return }
            deviceManager.eventQueueFired()
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
        deviceEvents.forEach{ _ = hidQueue.addElement(hidQueuePtrPtr, $0.rawElement, 0) }

        // Start
        guard hidQueue.start(hidQueuePtrPtr) == kIOReturnSuccess else {
            print("Unable to start queue")
            return
        }
        
        print("start monitor usb controller.")
    }
    
    func stopMonitor(device: Device) {
        if hidQueuePtrPtr != nil {
            _ = hidQueue?.stop(hidQueuePtrPtr)
            if let eventSource = hidQueue?.getAsyncEventSource(hidQueuePtrPtr)?.takeUnretainedValue(),
                CFRunLoopContainsSource(CFRunLoopGetCurrent(), eventSource, CFRunLoopMode.commonModes) {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), eventSource, CFRunLoopMode.commonModes)
            }
            _ = hidQueue?.Release(hidQueuePtrPtr)
            hidQueuePtrPtr = nil
            hidQueue = nil
        }
        if device.hidDevicePtrPtr != nil {
            _ = device.hidDevice!.close(device.hidDevicePtrPtr)
        }
        deviceEvents = []
    }
    
    func eventQueueFired() {
        print("event fired!!")
        guard let hidQueue = hidQueue else { return }
        var event: IOHIDEventStruct = IOHIDEventStruct()
        var result: IOReturn = kIOReturnSuccess
        mainLoop: while result == kIOReturnSuccess {
            result = hidQueue.getNextEvent(hidQueuePtrPtr, &event, event.timestamp, 0)
            
            guard result == kIOReturnSuccess else { continue }
            
            for deviceEvent in deviceEvents where deviceEvent.rawElement == event.elementCookie {
                print("event: \(deviceEvent.mode) value: \(event.value)")
                NotificationObserver.post(target: NotificationObserver.Target.deviceEventTriggered,
                                  param: deviceEvent.withValue(event.value))
            }
        }
    }
    
}
