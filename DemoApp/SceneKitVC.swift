//
//  SceneKitVC.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/3.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Cocoa
import SceneKit

class SceneKitVC: NSViewController {

    @IBOutlet weak var topSCNView: SCNView!
    @IBOutlet weak var leftSCNView: SCNView!
    @IBOutlet weak var rightSCNView: SCNView!
    @IBOutlet weak var mainSCNView: SCNView!
    let scene = SCNScene(named: "xboxController.scn")!
    
    @IBOutlet weak var slider1: NSSlider!
    @IBOutlet weak var slider2: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SceneHelper.basicConfig(scene: scene)
        
        mainSCNView.scene = scene
        scene.background.contents = NSColor.clear
        
        leftSCNView.scene = scene
        leftSCNView.allowsCameraControl = false
        leftSCNView.pointOfView = scene.rootNode.childNode(withName: "cameraLeft", recursively: true)
        
        rightSCNView.scene = scene
        rightSCNView.allowsCameraControl = false
        rightSCNView.pointOfView = scene.rootNode.childNode(withName: "cameraRight", recursively: true)
        
        topSCNView.scene = scene
        topSCNView.allowsCameraControl = false
        topSCNView.pointOfView = scene.rootNode.childNode(withName: "cameraTop", recursively: true)
        
        
        DeviceManager.shared.didTriggerEvent = { [weak self] event in
            guard let self = self else { return }
            
            SceneHelper.updateScene(scene: self.scene, event: event)
        }
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
    }
    @IBAction func tapButton1(_ sender: NSButton) {
        
    }
    @IBAction func changeCircleSlider(_ sender: NSSlider) {
        
    }
    
    @IBAction func changeSlider1(_ sender: NSSlider) {
        
    }
    @IBAction func changeSlider2(_ sender: NSSlider) {

    }
    
    func testUpdate() {
        if let leftStick = scene.rootNode.childNode(withName: "buttonL", recursively: true) {
            let material = leftStick.geometry!.firstMaterial!

            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5

            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5

                material.emission.contents = NSColor.black

                SCNTransaction.commit()
            }

            material.emission.contents = NSColor.red

            SCNTransaction.commit()
            
            let x = (slider1.doubleValue - 50) * 0.002 // -0.1...0.1
            let y = (slider2.doubleValue - 50) * 0.002 // -0.1...0.1
            let c1 = CATransform3DRotate(leftStick.pivot, CGFloat.pi * CGFloat(max(abs(x), abs(y))), CGFloat(x * 10), CGFloat(y * 10), 0)
            leftStick.transform = c1

            
        }
    }
}
