//
//  DeviceConfiguration.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/9.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

struct DeviceConfiguration: Codable {
    enum RumbleType: Int, Codable {
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
    class ButtonMapping: Codable {
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
    @Clamping(0...32767) var deadzoneLeft: Int = 0 // 0~32767
    @Clamping(0...32767) var deadzoneRight: Int = 0 // 0~32767
    var normalizeLeft: Bool = false
    var normalizeRight: Bool = false
    var linkedLeft: Bool = false
    var linkedRight: Bool = false
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
        normalizeLeft = detail["DeadOffLeft"] as? Bool ?? normalizeLeft
        normalizeRight = detail["DeadOffRight"] as? Bool ?? normalizeRight
        linkedLeft = detail["RelativeLeft"] as? Bool ?? linkedLeft
        linkedRight = detail["RelativeRight"] as? Bool ?? linkedRight
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
            "DeadOffLeft": normalizeLeft,
            "DeadOffRight": normalizeRight,
            "RelativeLeft": linkedLeft,
            "RelativeRight": linkedRight,
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
}

@propertyWrapper
struct Clamping<Value: Comparable & Codable>: Codable {
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
