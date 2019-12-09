//
//  DeviceConfiguration.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/9.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

struct DeviceConfiguration {
    enum RumbleType: Int {
        case `default` = 0
        case none
        case triggersOnly
        case both
        
        var name: String {
            switch self {
            case .default:
                return "Default"
            case .none:
                return "None"
            case .triggersOnly:
                return "Triggers Only"
            case .both:
                return "Both"
            }
        }
    }
    var invertLeftX: Bool = false
    var invertLeftY: Bool = false
    var invertRightX: Bool = false
    var invertRightY: Bool = false
    var deadzoneLeft: Int = 0
    var deadzoneRight: Int = 0
    var relativeLeft: Bool = false
    var relativeRight: Bool = false
    var deadOffLeft: Bool = false
    var deadOffRight: Bool = false
    var controllerType: Int = Device.ControlType.XboxOne.rawValue
    var rumbleType: Int = RumbleType.default.rawValue
    var bindingUp: Int = 0
    var bindingDown: Int = 1
    var bindingLeft: Int = 2
    var bindingRight: Int = 3
    var bindingStart: Int = 4
    var bindingBack: Int = 5
    var bindingLSC: Int = 6
    var bindingRSC: Int = 7
    var bindingLB: Int = 8
    var bindingRB: Int = 9
    var bindingGuide: Int = 10
    var bindingA: Int = 11
    var bindingB: Int = 12
    var bindingX: Int = 13
    var bindingY: Int = 14
    var swapSticks: Bool = false
    var pretend360: Bool = false
    
    init(_ detail:[String: Any]?) {
        guard let detail = detail else { return }
        
        invertLeftX = detail["InvertLeftX"] as? Bool ?? invertLeftX
        invertLeftY = detail["InvertLeftY"] as? Bool ?? invertLeftY
        invertRightX = detail["InvertRightX"] as? Bool ?? invertRightX
        invertRightY = detail["InvertRightY"] as? Bool ?? invertRightY
        deadzoneLeft = detail["DeadzoneLeft"] as? Int ?? deadzoneLeft
        deadzoneRight = detail["DeadzoneRight"] as? Int ?? deadzoneRight
        relativeLeft = detail["RelativeLeft"] as? Bool ?? relativeLeft
        relativeRight = detail["RelativeRight"] as? Bool ?? relativeRight
        deadOffLeft = detail["DeadOffLeft"] as? Bool ?? deadOffLeft
        deadOffRight = detail["DeadOffRight"] as? Bool ?? deadOffRight
        controllerType = detail["ControllerType"] as? Int ?? controllerType
        rumbleType = detail["RumbleType"] as? Int ?? rumbleType
        bindingUp = detail["BindingUp"] as? Int ?? bindingUp
        bindingDown = detail["BindingDown"] as? Int ?? bindingDown
        bindingLeft = detail["BindingLeft"] as? Int ?? bindingLeft
        bindingRight = detail["BindingRight"] as? Int ?? bindingRight
        bindingStart = detail["BindingStart"] as? Int ?? bindingStart
        bindingBack = detail["BindingBack"] as? Int ?? bindingBack
        bindingLSC = detail["BindingLSC"] as? Int ?? bindingLSC
        bindingRSC = detail["BindingRSC"] as? Int ?? bindingRSC
        bindingLB = detail["BindingLB"] as? Int ?? bindingLB
        bindingRB = detail["BindingRB"] as? Int ?? bindingRB
        bindingGuide = detail["BindingGuide"] as? Int ?? bindingGuide
        bindingA = detail["BindingA"] as? Int ?? bindingA
        bindingB = detail["BindingB"] as? Int ?? bindingB
        bindingX = detail["BindingX"] as? Int ?? bindingX
        bindingY = detail["BindingY"] as? Int ?? bindingY
        swapSticks = detail["SwapSticks"] as? Bool ?? swapSticks
        pretend360 = detail["Pretend360"] as? Bool ?? pretend360
        
    }
    
    func toDict() -> [String: Any] {
        return [
            "InvertLeftX": invertLeftX,
            "InvertLeftY": invertLeftY,
            "InvertRightX": invertRightX,
            "InvertRightY": invertRightY,
            "DeadzoneLeft": deadzoneLeft,
            "DeadzoneRight": deadzoneRight,
            "RelativeLeft": relativeLeft,
            "RelativeRight": relativeRight,
            "DeadOffLeft": deadOffLeft,
            "DeadOffRight": deadOffRight,
            "ControllerType": controllerType,
            "RumbleType": rumbleType,
            "BindingUp": bindingUp,
            "BindingDown": bindingDown,
            "BindingLeft": bindingLeft,
            "BindingRight": bindingRight,
            "BindingStart": bindingStart,
            "BindingBack": bindingBack,
            "BindingLSC": bindingLSC,
            "BindingRSC": bindingRSC,
            "BindingLB": bindingLB,
            "BindingRB": bindingRB,
            "BindingGuide": bindingGuide,
            "BindingA": bindingA,
            "BindingB": bindingB,
            "BindingX": bindingX,
            "BindingY": bindingY,
            "SwapSticks": swapSticks,
            "Pretend360": pretend360,
        ]
    }
}
