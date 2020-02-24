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
        
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(interfaceModeChanged(sender:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
//        view.window?.isOpaque = false
//        view.window?.backgroundColor = .clear
    }
    
    @objc
    func interfaceModeChanged(sender: NSNotification) {
        let isDarkMode: Bool = {
            if #available(OSX 10.14, *) {
                if NSApp.effectiveAppearance == NSAppearance(named: .darkAqua) {
                    return true
                }
            }
            return false
        }()
        
        if let node = scene.rootNode.childNode(withName: "body1", recursively: true) {
            node.geometry?.materials.first?.diffuse.contents = isDarkMode ? NSColor(0x1d1d1d) : NSColor(0xcecece)
        }
        
        if let node = scene.rootNode.childNode(withName: "button1a", recursively: true) {
            node.geometry?.materials.first?.diffuse.contents = isDarkMode ? NSColor(0x1d1d1d) : NSColor(0xcecece)
        }
        
        if let node = scene.rootNode.childNode(withName: "button2a", recursively: true) {
            node.geometry?.materials.first?.diffuse.contents = isDarkMode ? NSColor(0x1d1d1d) : NSColor(0xcecece)
        }
        
        if let node = scene.rootNode.childNode(withName: "button1b", recursively: true) {
            node.geometry?.materials.first?.diffuse.contents = isDarkMode ? NSColor(0xcecece) : NSColor(0x282828)
        }
        
        if let node = scene.rootNode.childNode(withName: "button2b", recursively: true) {
            node.geometry?.materials.first?.diffuse.contents = isDarkMode ? NSColor(0xcecece) : NSColor(0x282828)
        }
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
        configNodeLight(name: "cameraLeft", value: CGFloat(sender.floatValue * 20))
        configNodeLight(name: "cameraRight", value: CGFloat(sender.floatValue * 20))
        configNodeLight(name: "cameraTop", value: CGFloat(sender.floatValue * 10))
        
    }
    private func configNodeLight(name: String, value: CGFloat) {
        guard let node = scene.rootNode.childNode(withName: name, recursively: true) else { return }
        node.light?.intensity = value
    }
    @IBAction func changeSlider2(_ sender: NSSlider) {
        if let node = scene.rootNode.childNode(withName: "button_cross", recursively: true) {
            let rotate = CATransform3DRotate(node.pivot, CGFloat.pi * -CGFloat(sender.floatValue / 100 * 0.05), 1, 1, 0)
            node.transform = rotate
        }
    }
    
    private func config(layer: CAShapeLayer, addTo parentView: NSView) {
        let width = parentView.bounds.width
        let circularPath = NSBezierPath(roundedRect: parentView.bounds, xRadius: width * 0.5, yRadius: width * 0.5)

        layer.path = circularPath.cgPath
        layer.fillColor = NSColor.clear.cgColor
        layer.strokeColor = NSColor(red: 0.28, green: 0.55, blue: 0.21, alpha: 1.0).cgColor
        layer.lineCap = .butt
        layer.lineWidth = 10.0
        layer.strokeStart = 0
        layer.strokeEnd = 0

        parentView.layer?.addSublayer(layer)
    }
}
