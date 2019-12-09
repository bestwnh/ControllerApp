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
            if let button = DeviceEvent.Mode.Button(rawValue: usage - 1) {
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
    enum Axis: Int, DeviceEventModeProtocol {
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
        var nodeName: String {
            switch self {
            case .leftStickX,
                 .leftStickY:
                return "buttonL"
            case .rightStickX,
                 .rightStickY:
                return "buttonR"
            case .leftTrigger:
                return "buttonLT"
            case .rightTrigger:
                return "buttonRT"
            }
        }
    }

    enum Button: Int, DeviceEventModeProtocol {
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
        var nodeName: String {
            switch self {
            case .A:
                return "buttonA1"
            case .B:
                return "buttonB1"
            case .X:
                return "buttonX1"
            case .Y:
                return "buttonY1"
            case .LB:
                return "buttonLB"
            case .RB:
                return "buttonRB"
            case .LeftStick:
                return "buttonL"
            case .RightStick:
                return "buttonR"
            case .start:
                return "button2a"
            case .back:
                return "button1a"
            case .home:
                return "logo_white"
            case .up:
                return "button_cross"
            case .down:
                return "button_cross"
            case .left:
                return "button_cross"
            case .right:
                return "button_cross"
            }
        }
    }
}
