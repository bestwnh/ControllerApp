//
//  SceneHelper.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/9.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation
import SceneKit

class SceneHelper {
    static func basicConfig(scene: SCNScene) {
        configStickPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.leftStick.nodeName)
        configStickPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.rightStick.nodeName)

        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.a.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.b.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.x.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.y.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.back.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.start.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.home.nodeName)

        configTriggerPivot(scene: scene, nodeName: DeviceEvent.Mode.Axis.leftTrigger.nodeName)
        configTriggerPivot(scene: scene, nodeName: DeviceEvent.Mode.Axis.rightTrigger.nodeName)
        
        configTopButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.lb.nodeName, offset: 0.2)
        configTopButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.rb.nodeName, offset: -0.2)

    }
    
    static func updateScene(scene: SCNScene, event: DeviceEvent) {
        guard let node = scene.rootNode.childNode(withName: event.nodeName, recursively: true) else { return }

        func moveStick(x: Float, y: Float, value: Float) {
            let translate = CATransform3DTranslate(node.pivot, 0, 0, -CGFloat(value / 50))
            let rotate = CATransform3DRotate(translate, CGFloat.pi * CGFloat(max(abs(x), abs(y))), CGFloat(x * 10), CGFloat(y * 10), 0)
            node.transform = rotate
        }
        func tapButton(value: Float) {
            let translate = CATransform3DTranslate(node.pivot, 0, 0, -CGFloat(value / 50))
            node.transform = translate
        }
        func tapTopButton(value: Float, reverse: Bool) {
            let scaleValue: CGFloat = 0.01 * (reverse ? -1 : 1)
            let rotate = CATransform3DRotate(node.pivot, CGFloat.pi * scaleValue * CGFloat(value), 0, 0, 1)
            node.transform = rotate
        }
        func moveTrigger(value: Float) {
            let rotate = CATransform3DRotate(node.pivot, CGFloat.pi * -CGFloat(value * 0.01), 1, 0, 0)
            node.transform = rotate
        }
        
        switch event.mode {
        case .axis(.leftStickX), .axis(.leftStickY), .button(.leftStick):
            if let x = DeviceManager.shared.deviceEvent(mode: .axis(.leftStickY))?.value,
                let y = DeviceManager.shared.deviceEvent(mode: .axis(.leftStickX))?.value,
                let value = DeviceManager.shared.deviceEvent(mode: .button(.leftStick))?.value {
                moveStick(x: x, y: y, value: value)
            }
        case .axis(.rightStickX), .axis(.rightStickY), .button(.rightStick):
            if let x = DeviceManager.shared.deviceEvent(mode: .axis(.rightStickY))?.value,
                let y = DeviceManager.shared.deviceEvent(mode: .axis(.rightStickX))?.value,
                let value = DeviceManager.shared.deviceEvent(mode: .button(.rightStick))?.value {
                moveStick(x: x, y: y, value: value)
            }
        case .axis(.leftTrigger), .axis(.rightTrigger):
            if let value = DeviceManager.shared.deviceEvent(mode: event.mode)?.value {
                moveTrigger(value: value)
            }
            
        case .button(.a), .button(.b), .button(.x), .button(.y), .button(.back), .button(.start), .button(.home):
            if let value = DeviceManager.shared.deviceEvent(mode: event.mode)?.value {
                tapButton(value: value)
            }
        case .button(.up), .button(.down), .button(.left), .button(.right): break
        case .button(.lb):
            if let value = DeviceManager.shared.deviceEvent(mode: event.mode)?.value {
                tapTopButton(value: value, reverse: false)
            }
        case .button(.rb):
            if let value = DeviceManager.shared.deviceEvent(mode: event.mode)?.value {
                tapTopButton(value: value, reverse: true)
            }
        }
    }
}

fileprivate extension SceneHelper {
    static func configStickPivot(scene: SCNScene, nodeName: String) {
        guard let stick = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = stick.boundingSphere.center
        stick.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z - 0.055)
        stick.transform = stick.pivot
    }
    
    static func configButtonPivot(scene: SCNScene, nodeName: String) {
        guard let stick = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = stick.boundingSphere.center
        stick.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        stick.transform = stick.pivot
    }
    
    static func configTriggerPivot(scene: SCNScene, nodeName: String) {
        guard let stick = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = stick.boundingSphere.center
        stick.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z + 0.3)
        stick.transform = stick.pivot
    }
    static func configTopButtonPivot(scene: SCNScene, nodeName: String, offset: CGFloat) {
        guard let stick = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = stick.boundingSphere.center
        stick.pivot = SCNMatrix4MakeTranslation(center.x + offset, center.y, center.z)
        stick.transform = stick.pivot
    }
}
