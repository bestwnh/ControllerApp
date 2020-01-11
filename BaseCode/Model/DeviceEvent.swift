//
//  DeviceEvent.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/9.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

class DeviceEvent {
    enum Mode: Equatable {
        case axis(Axis)
        case button(Button)
    }
    let mode: Mode
    let rawElement: IOHIDElementCookie
    var value: Float = 0
    
    init?(element: [String: Any]) {
        // Get cookie
        guard let cookie: IOHIDElementCookie = (element[kIOHIDElementCookieKey] as? NSNumber)?.uint32Value else {
            return nil
        }
        
        // Get usage
        guard let usage: Int = (element[kIOHIDElementUsageKey] as? NSNumber)?.intValue else {
            return nil
        }
        
        // Get usage page
        guard let usagePage: Int = (element[kIOHIDElementUsagePageKey] as? NSNumber)?.intValue else {
            return nil
        }
        
        // Match up items
        switch (usagePage, usage) {
        case (0x01, 0x35): // Right trigger
            mode = .axis(.rightTrigger)
        case (0x01, 0x32): // Left trigger
            mode = .axis(.leftTrigger)
        case (0x01, 0x34): // Right stick Y
            mode = .axis(.rightStickY)
        case (0x01, 0x33): // Right stick X
            mode = .axis(.rightStickX)
        case (0x01, 0x31): // Left stick Y
            mode = .axis(.leftStickY)
        case (0x01, 0x30): // Left stick X
            mode = .axis(.leftStickX)
        case (0x09, 1...15):
            if let button = DeviceEvent.Mode.Button(usage: usage) {
                mode = .button(button)
            } else {
                return nil
            }
        default:
            return nil
        }
        
        self.rawElement = cookie
    }
    
    func withValue(_ value: Int32) -> Self {
        let floatValue = Float(value)
        switch mode {
        case .button:
            self.value = floatValue
        case .axis(.leftStickX),
             .axis(.leftStickY),
             .axis(.rightStickX),
             .axis(.rightStickY):
            self.value = floatValue / 327670
        case .axis(.leftTrigger),
             .axis(.rightTrigger):
            self.value = floatValue / 255
        }
        return self
    }
    
    var nodeName: String {
        switch mode {
        case let .axis(axis): return axis.nodeName
        case let .button(button): return button.nodeName
        }
    }
}

protocol DeviceEventModeProtocol {
    var title: String { get }
    var nodeName: String { get }
}

extension DeviceEvent.Mode {
    enum Axis: Int, DeviceEventModeProtocol, CaseIterable {
        case leftStickX = 0
        case leftStickY
        case rightStickX
        case rightStickY
        case leftTrigger
        case rightTrigger
        
        var title: String {
            switch self {
            case .leftStickX: return "leftStickX"
            case .leftStickY: return "leftStickY"
            case .rightStickX: return "rightStickX"
            case .rightStickY: return "rightStickY"
            case .leftTrigger: return "leftTrigger"
            case .rightTrigger: return "rightTrigger"
            }
        }
        var nodeName: String {
            switch self {
            case .leftStickX,
                 .leftStickY: return "buttonL"
            case .rightStickX,
                 .rightStickY: return "buttonR"
            case .leftTrigger: return "buttonLT"
            case .rightTrigger: return "buttonRT"
            }
        }
    }

    enum Button: Int, DeviceEventModeProtocol, CaseIterable {
        case a = 0
        case b
        case x
        case y
        case lb
        case rb
        case leftStick
        case rightStick
        case start
        case back
        case home
        case up
        case down
        case left
        case right
        
        init?(usage: Int) {
            if let button = Button(rawValue: usage - 1) {
                self = button
            } else {
                return nil
            }
        }
        init?(mappingValue: Int) {
            if let button = Button.allCases.first(where: { $0.mappingValue == mappingValue }) {
                self = button
            } else {
                return nil
            }
        }
        var title: String {
            switch self {
            case .a: return "A"
            case .b: return "B"
            case .x: return "X"
            case .y: return "Y"
            case .lb: return "LB"
            case .rb: return "RB"
            case .leftStick: return "LeftStick"
            case .rightStick: return "RightStick"
            case .start: return "Start"
            case .back: return "Back"
            case .home: return "Home"
            case .up: return "Up"
            case .down: return "Down"
            case .left: return "Left"
            case .right: return "Right"
            }
        }
        var configurationKey: String {
            switch self {
            case .a: return "BindingA"
            case .b: return "BindingB"
            case .x: return "BindingX"
            case .y: return "BindingY"
            case .lb: return "BindingLB"
            case .rb: return "BindingRB"
            case .leftStick: return "BindingLSC"
            case .rightStick: return "BindingRSC"
            case .start: return "BindingStart"
            case .back: return "BindingBack"
            case .home: return "BindingGuide"
            case .up: return "BindingUp"
            case .down: return "BindingDown"
            case .left: return "BindingLeft"
            case .right: return "BindingRight"
            }
        }
        var nodeName: String {
            switch self {
            case .a: return "buttonA1"
            case .b: return "buttonB1"
            case .x: return "buttonX1"
            case .y: return "buttonY1"
            case .lb: return "buttonLB"
            case .rb: return "buttonRB"
            case .leftStick: return "buttonL"
            case .rightStick: return "buttonR"
            case .start: return "button2a"
            case .back: return "button1a"
            case .home: return "logo_white"
            case .up: return "button_cross"
            case .down: return "button_cross"
            case .left: return "button_cross"
            case .right: return "button_cross"
            }
        }
        var mappingValue: Int {
            switch self {
            case .a: return 12
            case .b: return 13
            case .x: return 14
            case .y: return 15
            case .lb: return 8
            case .rb: return 9
            case .leftStick: return 6
            case .rightStick: return 7
            case .start: return 4
            case .back: return 5
            case .home: return 10
            case .up: return 0
            case .down: return 1
            case .left: return 2
            case .right: return 3
            }
        }
    }
}
