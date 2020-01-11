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
    class ButtonMapping {
        let orgButton: DeviceEvent.Mode.Button
        var mapToButton: DeviceEvent.Mode.Button
        
        init(orgButton: DeviceEvent.Mode.Button, mapTo mapToButton: DeviceEvent.Mode.Button) {
            self.orgButton = orgButton
            self.mapToButton = mapToButton
        }
        static func mappingList(fromDict dict: [String: Any]? = nil) -> [ButtonMapping] {
            DeviceEvent.Mode.Button.allCases.map({ orgButton in
                if let value = dict?[orgButton.configurationKey] as? Int,
                    let mapToButton = DeviceEvent.Mode.Button(mappingValue: value) {
                    return ButtonMapping(orgButton: orgButton, mapTo: mapToButton)
                } else {
                    return ButtonMapping(orgButton: orgButton, mapTo: orgButton)
                }
            })
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
    var swapSticks: Bool = false
    var pretend360: Bool = false
    var buttonMappingList: [ButtonMapping] = []
    
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
        swapSticks = detail["SwapSticks"] as? Bool ?? swapSticks
        pretend360 = detail["Pretend360"] as? Bool ?? pretend360
        buttonMappingList = ButtonMapping.mappingList(fromDict: detail)
        
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
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
            "SwapSticks": swapSticks,
            "Pretend360": pretend360,
            ]
        buttonMappingList.forEach{ dict[$0.orgButton.configurationKey] = $0.mapToButton.mappingValue }
        return dict
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
    mutating func resetButtonMapping() {
        buttonMappingList = ButtonMapping.mappingList()
    }
    mutating func update(orgButton: DeviceEvent.Mode.Button, mapTo mapToButton: DeviceEvent.Mode.Button) {
        let buttonMapping = ButtonMapping(orgButton: orgButton, mapTo: mapToButton)
        if let index = buttonMappingList.firstIndex(where: { $0.orgButton == orgButton }) {
            buttonMappingList[index] = buttonMapping
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
