//
//  ViewController.swift
//  DemoApp
//
//  Created by Galvin on 2019/11/17.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Cocoa

class ConfigurationVC: BaseVC {
    var device: Device?
    
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var swapSticksButton: NSButton!
    @IBOutlet weak var pretend360ControllerButton: NSButton!
    
    @IBOutlet weak var leftStickInvertX: NSButton!
    @IBOutlet weak var leftStickInvertY: NSButton!
    @IBOutlet weak var leftStickNormalize: NSButton!
    @IBOutlet weak var leftStickLinked: NSButton!
    @IBOutlet weak var leftDeadzoneSlider: NSSlider!
    @IBOutlet weak var leftCanvasView: StickDeadzoneView!
    
    @IBOutlet weak var rightStickInvertX: NSButton!
    @IBOutlet weak var rightStickInvertY: NSButton!
    @IBOutlet weak var rightStickNormalize: NSButton!
    @IBOutlet weak var rightStickLinked: NSButton!
    @IBOutlet weak var rightDeadzoneSlider: NSSlider!
    @IBOutlet weak var rightCanvasView: StickDeadzoneView!
    
    lazy var buttons: [NSButton] = [swapSticksButton, pretend360ControllerButton, leftStickInvertX, leftStickInvertY, rightStickInvertX, rightStickInvertY, leftStickNormalize, leftStickLinked, rightStickNormalize, rightStickLinked]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        output("App start")
        
        buttons.forEach{ $0.isEnabled = false }
        leftDeadzoneSlider.maxValue = 32767
        rightDeadzoneSlider.maxValue = 32767
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceEventTriggered) { [weak self] (buttonEvent) in
            guard let self = self else { return }
            guard let buttonEvent = buttonEvent else { return }
            switch buttonEvent.mode {
            case .axis(.leftStickX):
                self.updateLeftStickDeadzoneView(x: CGFloat(buttonEvent.value))
            case .axis(.leftStickY):
                self.updateLeftStickDeadzoneView(y: CGFloat(buttonEvent.value))
            case .axis(.rightStickX):
                self.updateRightStickDeadzoneView(x: CGFloat(buttonEvent.value))
            case .axis(.rightStickY):
                self.updateRightStickDeadzoneView(y: CGFloat(buttonEvent.value))
            default: break
            }
        }.handle(by: observerBag)
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceChanged) { [weak self] (_) in
            guard let self = self else { return }
            self.handleDeviceChanged()
        }.handle(by: observerBag)
    }
    
    func handleDeviceChanged() {
        if let device = DeviceManager.shared.currentDevice {
            output("binded device: \(device.displayName)")
            
            self.device = device
            print(device.configuration)
            swapSticksButton.state = device.configuration.swapSticks ? .on : .off
            pretend360ControllerButton.state = device.configuration.pretend360 ? .on : .off
            leftStickInvertX.state = device.configuration.invertLeftX ? .on : .off
            leftStickInvertY.state = device.configuration.invertLeftY ? .on : .off
            rightStickInvertX.state = device.configuration.invertRightX ? .on : .off
            rightStickInvertY.state = device.configuration.invertRightY ? .on : .off
            leftStickLinked.state = device.configuration.linkedLeft ? .on : .off
            rightStickLinked.state = device.configuration.linkedRight ? .on : .off
            leftStickNormalize.state = device.configuration.normalizeLeft ? .on : .off
            rightStickNormalize.state = device.configuration.normalizeRight ? .on : .off
            leftDeadzoneSlider.integerValue = device.configuration.deadzoneLeft
            rightDeadzoneSlider.integerValue = device.configuration.deadzoneRight
            
            buttons.forEach{ $0.isEnabled = true }
            leftDeadzoneSlider.isEnabled = true
            rightDeadzoneSlider.isEnabled = true

        } else {
            self.device = nil
            buttons.forEach{ $0.isEnabled = false }
            leftDeadzoneSlider.isEnabled = false
            rightDeadzoneSlider.isEnabled = false
        }
        updateLeftStickDeadzoneView()
        updateRightStickDeadzoneView()
    }
    
    func output(_ string: String) {
        self.textView.string = string + "\n" + self.textView.string
    }
    
    @IBAction func tapSwapSticksButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.swapSticks = sender.state.boolValue
        }
    }
    @IBAction func tapPretend360ControllerButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.pretend360 = sender.state.boolValue
            DeviceManager.shared.updateDeviceList()
        }
    }
    
    @IBAction func tapLeftStickInvertXButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertLeftX = sender.state.boolValue
        }
    }
    
    @IBAction func tapLeftStickInvertYButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertLeftY = sender.state.boolValue
        }
    }
    
    @IBAction func tapLeftStickNormalizeButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.normalizeLeft = sender.state.boolValue
        }
        updateLeftStickDeadzoneView()
    }
    
    @IBAction func tapLeftStickLinkedButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.linkedLeft = sender.state.boolValue
        }
        updateLeftStickDeadzoneView()
    }
    
    @IBAction func tapRightStickInvertXButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertRightX = sender.state.boolValue
        }
    }
    
    @IBAction func tapRightStickInvertYButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertRightY = sender.state.boolValue
        }
    }
    
    @IBAction func tapRightStickNormalizeButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.normalizeRight = sender.state.boolValue
        }
        updateRightStickDeadzoneView()
    }
    
    @IBAction func tapRightStickLinkedButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.linkedRight = sender.state.boolValue
        }
        updateRightStickDeadzoneView()
    }
    @IBAction func changeLeftDeadzoneSlider(_ sender: NSSlider) {
        if let device = self.device {
            device.configuration.deadzoneLeft = sender.integerValue
        }
        updateLeftStickDeadzoneView()
    }
    @IBAction func changeRightDeadzoneSlider(_ sender: NSSlider) {
        if let device = self.device {
            device.configuration.deadzoneRight = sender.integerValue
        }
        updateRightStickDeadzoneView()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func updateLeftStickDeadzoneView(x: CGFloat? = nil, y: CGFloat? = nil) {
        leftCanvasView.config(deadzone: leftDeadzoneSlider.integerValue,
                              isLinked: leftStickLinked.state.boolValue,
                              isNormalize: leftStickNormalize.state.boolValue,
                              x: x,
                              y: y)
    }
    private func updateRightStickDeadzoneView(x: CGFloat? = nil, y: CGFloat? = nil) {
        rightCanvasView.config(deadzone: rightDeadzoneSlider.integerValue,
                               isLinked: rightStickLinked.state.boolValue,
                               isNormalize: rightStickNormalize.state.boolValue,
                               x: x,
                               y: y)
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
