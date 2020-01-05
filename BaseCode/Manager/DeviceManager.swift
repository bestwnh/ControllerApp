//
//  DeviceManager.swift
//  ControllerApp
//
//  Created by Galvin on 2019/11/28.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation
import ForceFeedback
import ForceFeedback.ForceFeedbackConstants

final class DeviceManager {
    static let shared = DeviceManager()
    private init() {}
    
    var deviceList: [Device] = []
    private(set) var currentDevice: Device? {
        didSet {
            guard oldValue != currentDevice else { return }
            if let device = oldValue {
                stopMonitor(device: device)
            }
            guard let device = currentDevice else { return }
            startMonitor(device: device)
        }
    }
    
    private var usbDetector: IOUSBDetector?
    
    var deviceEvents: [DeviceEvent] = []
    var hidQueue: IOHIDQueueInterface?
    var hidQueuePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDQueueInterface>?>?
    
    var didTriggerEvent: (DeviceEvent) -> () = { _ in }

    var effect: FFEFFECT?
    var customForce: FFCUSTOMFORCE?
    var effectRef: FFEffectObjectReference?
    var largeMotor: Int32 = 0
    var smallMotor: Int32 = 0
    
    deinit {
        usbDetector?.stopDetection()
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
                print("Usb device changed.")
                self.updateDeviceList()
            }
        }
        _ = usbDetector?.startDetection()
    }
    func deviceEvent(mode: DeviceEvent.Mode) -> DeviceEvent? {
        return deviceEvents.first(where: { $0.mode == mode })
    }
}

private extension DeviceManager {
    func updateDeviceList() {
        deviceList = DriverHelper.getDeviceList()
        if let currentDevice = currentDevice, !deviceList.contains(currentDevice) {
            self.currentDevice = nil
        }
        
        if self.currentDevice == nil {
            self.currentDevice = deviceList.first
        }
    }
    
    func startMonitor(device: Device) {
        guard let hidDevice = device.hidDevice, let hidDevicePtrPtr = device.hidDevicePtrPtr else { return }
        var devicePathCString:[CChar] = [CChar](repeating: 0, count: 128)
        IORegistryEntryGetPath(device.rawDevice, "IOService", &devicePathCString)
        
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
        
        startRumbleMotor()
        activeRumbleMotor(large: 0, small: 0)
        largeMotor = 0
        smallMotor = 0
        
        print("started.")
    }
    
    func stopMonitor(device: Device) {
        activeRumbleMotor(large: 0, small: 0)
        stopRumbleMotor()
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
                didTriggerEvent(deviceEvent.withValue(event.value))
                switch deviceEvent.mode {
                case .axis(.leftTrigger):
                    largeMotor = event.value
                    self.activeRumbleMotor(large: largeMotor, small: smallMotor)
                case .axis(.rightTrigger):
                    smallMotor = event.value
                    self.activeRumbleMotor(large: largeMotor, small: smallMotor)
                default: break
                }
            }
        }
    }
    
    func startRumbleMotor() {
        guard let ffDevice = currentDevice?.ffDevice else { return }
        var capabs = FFCAPABILITIES()
        FFDeviceGetForceFeedbackCapabilities(ffDevice, &capabs)
        
        guard capabs.numFfAxes == 2 else { return }
        
        var effect = calloc(1, MemoryLayout<FFEFFECT>.size).load(as: FFEFFECT.self)
        var customForce = calloc(1, MemoryLayout<FFCUSTOMFORCE>.size).load(as: FFCUSTOMFORCE.self)
        self.effect = effect
        self.customForce = customForce
        
        let rglForceData = calloc(2, MemoryLayout<LPLONG>.size).load(as: LPLONG.self)
        let rgdwAxes = calloc(2, MemoryLayout<LPDWORD>.size).load(as: LPDWORD.self)
        let rglDirection = calloc(2, MemoryLayout<LPLONG>.size).load(as: LPLONG.self)
        
        rglForceData[0] = 0
        rglForceData[1] = 0
        rgdwAxes[0] = DWORD(capabs.ffAxes.0)
        rgdwAxes[1] = DWORD(capabs.ffAxes.1)
        rglDirection[0] = 0
        rglDirection[1] = 0
        
        customForce.cChannels = 2
        customForce.cSamples = 2
        customForce.rglForceData = rglForceData
        customForce.dwSamplePeriod = 100_000
        
        effect.cAxes = capabs.numFfAxes
        effect.rglDirection = rglDirection
        effect.rgdwAxes = rgdwAxes
        effect.dwSamplePeriod = 0
        effect.dwGain = 10000
        effect.dwFlags = DWORD(FFEFF_OBJECTOFFSETS) | DWORD(FFEFF_SPHERICAL)
        effect.dwSize = DWORD(MemoryLayout<FFEFFECT>.size)
        effect.dwDuration = DWORD(FF_INFINITE)
        effect.dwSamplePeriod = 100_000
        effect.cbTypeSpecificParams = DWORD(MemoryLayout<FFCUSTOMFORCE>.size)
        effect.lpvTypeSpecificParams = UnsafeMutableRawPointer(&customForce)
        effect.lpEnvelope = nil
        FFDeviceCreateEffect(ffDevice, kFFEffectType_CustomForce_ID, &effect, &effectRef)
    }
    
    func stopRumbleMotor() {
        guard effectRef != nil else { return }
        
        FFDeviceReleaseEffect(currentDevice?.ffDevice, effectRef)
        if customForce != nil {
            free(customForce?.rglForceData)
            free(&customForce)
            customForce = nil
        }
        if effect != nil {
            free(effect?.rgdwAxes)
            free(effect?.rglDirection)
            free(&effect)
            effect = nil
        }
    }
    func activeRumbleMotor(large: Int32, small: Int32) {
        guard effectRef != nil, effect != nil else { return }
        print("large: \(large) small: \(small)")
        customForce?.rglForceData[0] = LONG(large * 10000 / 255)
        customForce?.rglForceData[1] = LONG(small * 10000 / 255)
        FFEffectSetParameters(effectRef, &effect!, FFEP_TYPESPECIFICPARAMS)
        FFEffectStart(effectRef, 1, 0)
    }
}
