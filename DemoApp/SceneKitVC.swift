//
//  SceneKitVC.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/3.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Cocoa
import SceneKit

class SceneKitVC: BaseVC {
    
    @IBOutlet weak var leftSCNView: SCNView!
    @IBOutlet weak var rightSCNView: SCNView!
    @IBOutlet weak var mainSCNView: SCNView!
    let scene = SCNScene(named: "xboxController.scn")!
    private let leftProgressLayer = CAShapeLayer()
    private let rightProgressLayer = CAShapeLayer()

    @IBOutlet weak var slider1: NSSlider!
    @IBOutlet weak var slider2: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SceneHelper.basicConfig(scene: scene)
        
        mainSCNView.scene = scene
        mainSCNView.scene?.background.contents = NSColor.clear
        mainSCNView.allowsCameraControl = false
        mainSCNView.pointOfView = scene.rootNode.childNode(withName: "cameraTop", recursively: true)

        leftSCNView.wantsLayer = true
        leftSCNView.scene = scene
        leftSCNView.scene?.background.contents = NSColor.clear
        leftSCNView.allowsCameraControl = false
        leftSCNView.pointOfView = scene.rootNode.childNode(withName: "cameraLeft", recursively: true)
        leftSCNView.layer?.cornerRadius = 25
        leftSCNView.layer?.borderWidth = 2
        leftSCNView.layer?.borderColor = NSColor(deviceWhite: 0.5, alpha: 0.8).cgColor
        config(layer: leftProgressLayer, addTo: leftSCNView)
        
        rightSCNView.wantsLayer = true
        rightSCNView.scene = scene
        rightSCNView.scene?.background.contents = NSColor.clear
        rightSCNView.allowsCameraControl = false
        rightSCNView.pointOfView = scene.rootNode.childNode(withName: "cameraRight", recursively: true)
        rightSCNView.layer?.cornerRadius = 25
        rightSCNView.layer?.borderWidth = 2
        rightSCNView.layer?.borderColor = NSColor(deviceWhite: 0.5, alpha: 0.8).cgColor
        config(layer: rightProgressLayer, addTo: rightSCNView)
        
        if let path = Bundle.main.path(forResource: "MirrorCamera", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                let technique = SCNTechnique(dictionary:dict2)
                leftSCNView.technique = technique
                rightSCNView.technique = technique
            }
        }
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceEventTriggered) { [weak self] (buttonEvent) in
            guard let self = self else { return }
            guard let buttonEvent = buttonEvent else { return }
            SceneHelper.updateScene(scene: self.scene, event: buttonEvent)
            switch buttonEvent.mode {
                case .axis(.leftTrigger):
                    print(buttonEvent.value)
                    self.leftProgressLayer.strokeEnd = CGFloat(buttonEvent.value)
                case .axis(.rightTrigger):
                    self.rightProgressLayer.strokeEnd = CGFloat(buttonEvent.value)
                default: break
            }
        }.handle(by: observerBag)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
//        view.window?.isOpaque = false
//        view.window?.backgroundColor = .clear
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
    }
    @IBAction func tapButton1(_ sender: NSButton) {
        print(DeviceManager.shared.currentDevice?.configuration)
    }
    @IBAction func changeCircleSlider(_ sender: NSSlider) {
        
    }
    
    @IBAction func changeSlider1(_ sender: NSSlider) {
       
    }
    @IBAction func changeSlider2(_ sender: NSSlider) {

    }
    
    private func config(layer: CAShapeLayer, addTo parentView: NSView) {
        let width = parentView.bounds.width
        let circularPath = NSBezierPath(roundedRect: parentView.bounds, xRadius: width * 0.5, yRadius: width * 0.5)

        layer.path = circularPath.cgPath
        layer.fillColor = NSColor.clear.cgColor
        layer.strokeColor = NSColor.red.cgColor
        layer.lineCap = .butt
        layer.lineWidth = 10.0
        layer.strokeStart = 0
        layer.strokeEnd = 0

        parentView.layer?.addSublayer(layer)
    }
}
