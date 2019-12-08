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
    
    var deviceList: [Device] = []
    private(set) var currentDevice: Device? {
        didSet {
            guard oldValue != currentDevice else { return }
            oldValue?.stop()
            currentDevice?.start()
        }
    }
    
    private var usbDetector: IOUSBDetector?
    
    deinit {
        usbDetector?.stopDetection()
    }
}

extension DeviceManager {
    func selectedDevice(atIndex index: Int) {
        currentDevice = deviceList[safe: index]
    }
    func startMonitorDeviceChange() {
        usbDetector = IOUSBDetector()
        
        usbDetector?.callbackQueue = DispatchQueue.global()
        usbDetector?.callback = { [weak self] (detector, event, service) in
            guard let self = self else { return }
            // wait a second for get device ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("Usb device changed.")
                self.updateDeviceList()
            }
        };
        _ = usbDetector?.startDetection()
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
}
