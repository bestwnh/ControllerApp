//
//  MainVC.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/8.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa
import SceneKit

class MainVC: BaseVC {

    @IBOutlet weak var controllerSceneView: SCNView!
    @IBOutlet weak var leftTriggerSceneView: SCNView!
    @IBOutlet weak var rightTriggerSceneView: SCNView!
    @IBOutlet weak var leftStickDeadzoneView: StickDeadzoneView!
    @IBOutlet weak var rightStickDeadzoneView: StickDeadzoneView!
    
    private let scene = SCNScene(named: "xboxController.scn")!
    private lazy var leftTriggerCircle = TriggerCircle(sceneView: leftTriggerSceneView, side: .left)
    private lazy var rightTriggerCircle = TriggerCircle(sceneView: rightTriggerSceneView, side: .right)
    
    @IBOutlet weak var swapStickButton: CheckboxButton!
    @IBOutlet weak var pretendTo360ControllerButton: CheckboxButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SceneHelper.reset(scene: scene)
        
        initSceneView()
        
        updateOtherSetting()
        
        NotificationObserver.addDistributedObserver(target: NotificationObserver.Target.DistributedNotification.uiModeChanged) { [weak self] (_) in
            
            let cellColor = AppState.isDarkMode ? NSColor(0x1d1d1d) : NSColor(0xcecece)
            let contentColor = AppState.isDarkMode ? NSColor(0xcecece) : NSColor(0x282828)
            
            func updateNode(name:String, color: NSColor) {
                self?.scene.rootNode.childNode(withName: name, recursively: true)?
                    .geometry?.materials.first?.diffuse.contents = color
            }
            updateNode(name: "body1", color: cellColor)
            updateNode(name: "button1a", color: cellColor)
            updateNode(name: "button2a", color: cellColor)
            updateNode(name: "button1b", color: contentColor)
            updateNode(name: "button2b", color: contentColor)

        }.handle(by: observerBag)
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.currentDeviceChanged) { [weak self] (_) in
            guard let self = self else { return }
            SceneHelper.reset(scene: self.scene)
            self.updateStickDeadzoneView(side: .left)
            self.updateStickDeadzoneView(side: .right)
            self.updateOtherSetting()
        }.handle(by: observerBag)
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceConfigurationChanged) { [weak self] (_) in
            self?.updateStickDeadzoneView(side: .left)
            self?.updateStickDeadzoneView(side: .right)
        }.handle(by: observerBag)
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceEventTriggered) { [weak self] (buttonEvent) in
            guard let self = self else { return }
            guard let buttonEvent = buttonEvent else { return }
            SceneHelper.updateScene(scene: self.scene, event: buttonEvent)
            switch buttonEvent.mode {
            case .axis(.leftStickX):
                self.updateStickDeadzoneView(side: .left, x: CGFloat(buttonEvent.value))
            case .axis(.leftStickY):
                self.updateStickDeadzoneView(side: .left, y: CGFloat(buttonEvent.value))
            case .axis(.rightStickX):
                self.updateStickDeadzoneView(side: .right, x: CGFloat(buttonEvent.value))
            case .axis(.rightStickY):
                self.updateStickDeadzoneView(side: .right, y: CGFloat(buttonEvent.value))
            case .axis(.leftTrigger):
                self.leftTriggerCircle.config(percent: CGFloat(buttonEvent.value))
            case .axis(.rightTrigger):
                self.rightTriggerCircle.config(percent: CGFloat(buttonEvent.value))
            default: break
            }
        }.handle(by: observerBag)
    }

    @IBAction func toggleSwapStickButton(_ sender: NSButton) {
        guard let device = DeviceManager.shared.currentDevice else { return }
        device.configuration.swapSticks = sender.boolState
    }
    @IBAction func togglePretendTo360ControllerButton(_ sender: NSButton) {
        guard let device = DeviceManager.shared.currentDevice else { return }
        device.configuration.pretend360 = sender.boolState
        DeviceManager.shared.updateDeviceList()
    }
}

private extension MainVC {
    func initSceneView() {
        controllerSceneView.scene = scene
        controllerSceneView.pointOfView = scene.rootNode.childNode(withName: "cameraTop", recursively: true)
        
        leftTriggerSceneView.scene = scene
        leftTriggerSceneView.pointOfView = scene.rootNode.childNode(withName: "cameraLeft", recursively: true)
        SceneHelper.mirror(sceneView: leftTriggerSceneView)
        leftTriggerCircle.config(percent: 0)
        
        rightTriggerSceneView.scene = scene
        rightTriggerSceneView.pointOfView = scene.rootNode.childNode(withName: "cameraRight", recursively: true)
        SceneHelper.mirror(sceneView: rightTriggerSceneView)
        rightTriggerCircle.config(percent: 0)
    }

    func updateStickDeadzoneView(side: StickVC.Side, x: CGFloat? = nil, y: CGFloat? = nil) {
        guard let configuration = DeviceManager.shared.currentDevice?.configuration else { return }
        let targetView: StickDeadzoneView = {
            switch (side, configuration.swapSticks) {
            case (.left, false), (.left, true):
                return leftStickDeadzoneView
            case (.right, true), (.right, false):
                return rightStickDeadzoneView
            }
        }()
        
        switch (side, configuration.swapSticks) {
        case (.left, false), (.right, true):
            targetView.config(deadzone: configuration.deadzoneLeft,
                              isLinked: configuration.linkedLeft,
                              isNormalize: configuration.normalizeLeft,
                              x: x,
                              y: y)
        case (.left, true), (.right, false):
            targetView.config(deadzone: configuration.deadzoneRight,
                              isLinked: configuration.linkedRight,
                              isNormalize: configuration.normalizeRight,
                              x: x,
                              y: y)
        }
    }

    func updateOtherSetting() {
        if let configuration = DeviceManager.shared.currentDevice?.configuration {
            self.swapStickButton.boolState = configuration.swapSticks
            self.pretendTo360ControllerButton.boolState = configuration.pretend360
            self.swapStickButton.isEnabled = true
            self.pretendTo360ControllerButton.isEnabled = true
        } else {
            self.swapStickButton.boolState = false
            self.pretendTo360ControllerButton.boolState = false
            self.swapStickButton.isEnabled = false
            self.pretendTo360ControllerButton.isEnabled = false
        }
    }
}
