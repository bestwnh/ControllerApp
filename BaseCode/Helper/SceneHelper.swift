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
    static func mirror(sceneView: SCNView) {
        guard let filePath = Bundle.main.path(forResource: "MirrorCamera", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject] else { return }
        let technique = SCNTechnique(dictionary:dict)
        sceneView.technique = technique
    }
    static func configTriggerSceneView(_ sceneView: SCNView) {
        
    }
    static func reset(scene: SCNScene) {
        configStickPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.leftStick.nodeName)
        configStickPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.rightStick.nodeName)

        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.a.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.b.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.x.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.y.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.back.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.start.nodeName)
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.home.nodeName)
        
        // cross button is four event in one button, just need to config one of them
        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.left.nodeName)
//        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.right.nodeName)
//        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.up.nodeName)
//        configButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.down.nodeName)

        configTriggerPivot(scene: scene, nodeName: DeviceEvent.Mode.Axis.leftTrigger.nodeName)
        configTriggerPivot(scene: scene, nodeName: DeviceEvent.Mode.Axis.rightTrigger.nodeName)
        
        configTopButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.lb.nodeName, offset: 0.2)
        configTopButtonPivot(scene: scene, nodeName: DeviceEvent.Mode.Button.rb.nodeName, offset: -0.2)
    }
    static func highlightNode(_ node: SCNNode, shouldHighlight: Bool) {
        
        let material = node.geometry!.firstMaterial!

        SCNTransaction.begin()

        if let color = material.diffuse.contents as? NSColor, color == NSColor(0xcecece) {
            material.multiply.contents = shouldHighlight ? NSColor.gray : NSColor.white
        } else {
            material.emission.contents = shouldHighlight ? NSColor.gray : NSColor.black
        }

        SCNTransaction.commit()
    }
    
    static func updateScene(scene: SCNScene, event: DeviceEvent) {
        guard let node = scene.rootNode.childNode(withName: event.nodeName, recursively: true) else { return }

        func moveStick(x: Float, y: Float, value: Float) {
            let translate = CATransform3DTranslate(node.pivot, 0, 0, -CGFloat(value / 50))
            let rotate = CATransform3DRotate(translate, CGFloat.pi * CGFloat(sqrt(x * x + y * y) / 10), CGFloat(x), CGFloat(y), 0)
            node.transform = rotate
            highlightNode(node, shouldHighlight: x != 0 || y != 0 || value != 0)
        }
        func tapButton(value: Float) {
            let translate = CATransform3DTranslate(node.pivot, 0, 0, -CGFloat(value / 50))
            node.transform = translate
            highlightNode(node, shouldHighlight: value != 0)
        }
        func tapCrossButton(x: Float, y: Float) {
            let rotate = CATransform3DRotate(node.pivot, CGFloat.pi * -CGFloat(sqrt(x * x + y * y)) * 0.05, CGFloat(x), CGFloat(y), 0)
            node.transform = rotate
            highlightNode(node, shouldHighlight: x != 0 || y != 0)
        }
        func tapTopButton(value: Float, reverse: Bool) {
            let scaleValue: CGFloat = 0.01 * (reverse ? -1 : 1)
            let rotate = CATransform3DRotate(node.pivot, CGFloat.pi * scaleValue * CGFloat(value), 0, 0, 1)
            node.transform = rotate
            highlightNode(node, shouldHighlight: value != 0)
        }
        func moveTrigger(value: Float) {
            let rotate = CATransform3DRotate(node.pivot, CGFloat.pi * -CGFloat(value * 0.08), 1, 0, 0)
            node.transform = rotate
            highlightNode(node, shouldHighlight: value != 0)
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
        case .button(.up), .button(.down), .button(.left), .button(.right):
            if let up = DeviceManager.shared.deviceEvent(mode: .button(.up))?.value,
                let down = DeviceManager.shared.deviceEvent(mode: .button(.down))?.value,
                let left = DeviceManager.shared.deviceEvent(mode: .button(.left))?.value,
                let right = DeviceManager.shared.deviceEvent(mode: .button(.right))?.value {
                let x: Float = {
                    if up > 0 { return 1 }
                    if down > 0 { return -1 }
                    return 0
                }()
                let y: Float = {
                    if left > 0 { return 1 }
                    if right > 0 { return -1 }
                    return 0
                }()
                tapCrossButton(x: x, y: y)
            }
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
        guard let node = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = node.boundingSphere.center
        node.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z - 0.055)
        node.transform = node.pivot
        highlightNode(node, shouldHighlight: false)
    }
    
    static func configButtonPivot(scene: SCNScene, nodeName: String) {
        guard let node = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = node.boundingSphere.center
        node.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        node.transform = node.pivot
        highlightNode(node, shouldHighlight: false)
    }
    
    static func configTriggerPivot(scene: SCNScene, nodeName: String) {
        guard let node = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = node.boundingSphere.center
        node.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z + 0.3)
        node.transform = node.pivot
        highlightNode(node, shouldHighlight: false)
    }
    static func configTopButtonPivot(scene: SCNScene, nodeName: String, offset: CGFloat) {
        guard let node = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let center = node.boundingSphere.center
        node.pivot = SCNMatrix4MakeTranslation(center.x + offset, center.y, center.z)
        node.transform = node.pivot
        highlightNode(node, shouldHighlight: false)
    }
}
