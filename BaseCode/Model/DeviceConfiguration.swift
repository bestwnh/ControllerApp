//
//  DeviceConfiguration.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/9.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

struct DeviceConfiguration {
    enum Button: Int {
        case up = 1
        case down
        case left
        case right
        case start
        case back
        case lsc
        case rsc
        case lb
        case rb
        case guide
        case a
        case b
        case x
        case y
    }
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
    var bindingUp: Int = Button.up.rawValue
    var bindingDown: Int = Button.down.rawValue
    var bindingLeft: Int = Button.left.rawValue
    var bindingRight: Int = Button.right.rawValue
    var bindingStart: Int = Button.start.rawValue
    var bindingBack: Int = Button.back.rawValue
    var bindingLSC: Int = Button.lsc.rawValue
    var bindingRSC: Int = Button.rsc.rawValue
    var bindingLB: Int = Button.lb.rawValue
    var bindingRB: Int = Button.rb.rawValue
    var bindingGuide: Int = Button.guide.rawValue
    var bindingA: Int = Button.a.rawValue
    var bindingB: Int = Button.b.rawValue
    var bindingX: Int = Button.x.rawValue
    var bindingY: Int = Button.y.rawValue
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
