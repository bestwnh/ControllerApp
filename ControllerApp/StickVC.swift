//
//  StickVC.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/9.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class StickVC: BaseVC {
    private enum Side {
        case left
        case right
    }
    @IBOutlet weak var invertXButton: NSButton!
    @IBOutlet weak var invertYButton: NSButton!
    @IBOutlet weak var normalizeButton: NSButton!
    @IBOutlet weak var linkedButton: NSButton!
    
    @IBOutlet weak var deadzoneSlider: NSSlider!
    
    private var side: Side {
        switch title {
        case .some("LeftStick"):
            return .left
        case .some("RightStick"):
            return .right
        default:
            return .left
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        NotificationObserver.addObserver(target: NotificationObserver.Target.currentDeviceChanged) { [weak self] _ in
            self?.updateView()
        }.handle(by: observerBag)
    }
    
    private func updateView() {
        let buttons = [invertXButton, invertYButton, normalizeButton, linkedButton]
        if let configuration = DeviceManager.shared.currentDevice?.configuration {
            buttons.forEach{
                $0?.isEnabled = true
            }
            switch side {
            case .left:
                invertXButton.boolState = configuration.invertLeftX
                invertYButton.boolState = configuration.invertLeftY
                normalizeButton.boolState = configuration.normalizeLeft
                linkedButton.boolState = configuration.linkedLeft
                deadzoneSlider.floatValue = configuration.deadzoneLeftPrecent
            case .right:
                invertXButton.boolState = configuration.invertRightX
                invertYButton.boolState = configuration.invertRightY
                normalizeButton.boolState = configuration.normalizeRight
                linkedButton.boolState = configuration.linkedRight
                deadzoneSlider.floatValue = configuration.deadzoneRightPrecent
            }
        } else {
            buttons.forEach{
                $0?.state = .off
                $0?.isEnabled = false
            }
            deadzoneSlider.floatValue = 0
        }
    }
    
    @IBAction func toggleInvertXButton(_ sender: NSButton) {
        guard let device = DeviceManager.shared.currentDevice else { return }
        switch side {
        case .left:
            device.configuration.invertLeftX = sender.boolState
        case .right:
            device.configuration.invertRightX = sender.boolState
        }
    }
    
    @IBAction func toggleInvertYButton(_ sender: NSButton) {
        guard let device = DeviceManager.shared.currentDevice else { return }
        switch side {
        case .left:
            device.configuration.invertLeftY = sender.boolState
        case .right:
            device.configuration.invertRightY = sender.boolState
        }
    }
    
    @IBAction func toggleNormalizeButton(_ sender: NSButton) {
        guard let device = DeviceManager.shared.currentDevice else { return }
        switch side {
        case .left:
            device.configuration.normalizeLeft = sender.boolState
        case .right:
            device.configuration.normalizeRight = sender.boolState
        }
    }
    
    @IBAction func toggleLinkedButton(_ sender: NSButton) {
        guard let device = DeviceManager.shared.currentDevice else { return }
        switch side {
        case .left:
            device.configuration.linkedLeft = sender.boolState
        case .right:
            device.configuration.linkedRight = sender.boolState
        }
    }
    
    @IBAction func changeRightDeadzoneSlider(_ sender: NSSlider) {
        guard let device = DeviceManager.shared.currentDevice else { return }
        switch side {
        case .left:
            device.configuration.deadzoneLeftPrecent = sender.floatValue
        case .right:
            device.configuration.deadzoneRightPrecent = sender.floatValue
        }
    }
}


