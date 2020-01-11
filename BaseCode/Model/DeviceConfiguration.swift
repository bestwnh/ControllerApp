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
    @Clamping(0...32768) var deadzoneLeft: Int = 0 // 0~32768
    @Clamping(0...32768) var deadzoneRight: Int = 0 // 0~32768
    var relativeLeft: Bool = false
    var relativeRight: Bool = false
    var deadOffLeft: Bool = false
    var deadOffRight: Bool = false
    var controllerType: Int = Device.ControlType.XboxOne.rawValue
    var rumbleType: Int = RumbleType.default.rawValue
    var bindingUp: Int = DeviceEvent.Mode.Button.up.mappingValue
    var bindingDown: Int = DeviceEvent.Mode.Button.down.mappingValue
    var bindingLeft: Int = DeviceEvent.Mode.Button.left.mappingValue
    var bindingRight: Int = DeviceEvent.Mode.Button.right.mappingValue
    var bindingStart: Int = DeviceEvent.Mode.Button.start.mappingValue
    var bindingBack: Int = DeviceEvent.Mode.Button.back.mappingValue
    var bindingLSC: Int = DeviceEvent.Mode.Button.leftStick.mappingValue
    var bindingRSC: Int = DeviceEvent.Mode.Button.rightStick.mappingValue
    var bindingLB: Int = DeviceEvent.Mode.Button.lb.mappingValue
    var bindingRB: Int = DeviceEvent.Mode.Button.rb.mappingValue
    var bindingGuide: Int = DeviceEvent.Mode.Button.home.mappingValue
    var bindingA: Int = DeviceEvent.Mode.Button.a.mappingValue
    var bindingB: Int = DeviceEvent.Mode.Button.b.mappingValue
    var bindingX: Int = DeviceEvent.Mode.Button.x.mappingValue
    var bindingY: Int = DeviceEvent.Mode.Button.y.mappingValue
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
    
    var deadzoneLeftPrecent: Float {
        set {
            deadzoneLeft = Int(newValue * 32768)
        }
        get {
            return Float(deadzoneLeft) / 32768
        }
    }
    var deadzoneRightPrecent: Float {
        set {
            deadzoneRight = Int(newValue * 32768)
        }
        get {
            return Float(deadzoneRight) / 32768
        }
    }
}

@propertyWrapper
struct Clamping<Value: Comparable> {
  var value: Value
  let range: ClosedRange<Value>

  init(wrappedValue: Value, _ range: ClosedRange<Value>) {
    precondition(range.contains(wrappedValue))
    self.value = wrappedValue
    self.range = range
  }

  var wrappedValue: Value {
    get { value }
    set { value = min(max(range.lowerBound, newValue), range.upperBound) }
  }
}
