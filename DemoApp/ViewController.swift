//
//  ViewController.swift
//  DemoApp
//
//  Created by Galvin on 2019/11/17.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    var device: Device?
    
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var swapSticksButton: NSButton!
    
    @IBOutlet weak var leftStickInvertX: NSButton!
    @IBOutlet weak var leftStickInvertY: NSButton!
    
    @IBOutlet weak var rightStickInvertX: NSButton!
    @IBOutlet weak var rightStickInvertY: NSButton!
    
    lazy var buttons: [NSButton] = [swapSticksButton, leftStickInvertX, leftStickInvertY, rightStickInvertX, rightStickInvertY]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        output("App start")
        
        buttons.forEach{ $0.isEnabled = false }
        
        DeviceManager.shared.startMonitorDeviceChange()
        
        
    }
    
    func checkDeviceList() {
        guard self.device == nil else { return }
        let devices = DriverHelper.getDeviceList()
        if let device = devices.first {
            output("binded device: \(device.displayName)")
            
            self.device = device
            print(device.configuration)
            swapSticksButton.state = device.configuration.swapSticks ? .on : .off
            leftStickInvertX.state = device.configuration.invertLeftX ? .on : .off
            leftStickInvertY.state = device.configuration.invertLeftY ? .on : .off
            rightStickInvertX.state = device.configuration.invertRightX ? .on : .off
            rightStickInvertY.state = device.configuration.invertRightY ? .on : .off
            
            buttons.forEach{ $0.isEnabled = true }
            
        } else {
            self.device = nil
            buttons.forEach{ $0.isEnabled = false }
        }
    }
    
    func output(_ string: String) {
        self.textView.string = string + "\n" + self.textView.string
    }
    
    @IBAction func tapSwapSticksButton(_ sender: Any) {
        if let device = self.device {
            device.configuration.swapSticks = swapSticksButton.state.boolValue
        }
    }
    
    @IBAction func tapLeftStickInvertXButton(_ sender: Any) {
        if let device = self.device {
            device.configuration.invertLeftX = leftStickInvertX.state.boolValue
        }
    }
    
    @IBAction func tapLeftStickInvertYButton(_ sender: Any) {
        if let device = self.device {
            device.configuration.invertLeftY = leftStickInvertY.state.boolValue
        }
    }
    
    @IBAction func tapRightStickInvertXButton(_ sender: Any) {
        if let device = self.device {
            device.configuration.invertRightX = rightStickInvertX.state.boolValue
        }
    }
    
    @IBAction func tapRightStickInvertYButton(_ sender: Any) {
        if let device = self.device {
            device.configuration.invertRightY = rightStickInvertY.state.boolValue
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension NSControl.StateValue {
    
    var boolValue: Bool {
        switch self {
        case .on:
            return true
        default:
            return false
        }
    }
}
