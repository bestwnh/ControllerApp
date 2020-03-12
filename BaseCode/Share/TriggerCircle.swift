//
//  TriggerCircle.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/9.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa
import SceneKit

class TriggerCircle {
    enum Side {
        case left, right
    }
    private let progressLayer: CAShapeLayer = .init()
    
    init(sceneView: SCNView, side: Side) {
        sceneView.wantsLayer = true
        sceneView.layer?.masksToBounds = false
        
        let width = sceneView.bounds.width
        let origin: CGPoint = {
            switch side {
            case .left: return .init(x: 5, y: 0)
            case .right: return .init(x: -5, y: 0)
            }
        }()
        let circlePath = NSBezierPath(
            roundedRect: NSRect(origin: origin, size: sceneView.bounds.size),
            xRadius: width * 0.5,
            yRadius: width * 0.5
        )
        
        let bgLayer = CAShapeLayer()
        bgLayer.strokeColor = NSColor(0x06415e).cgColor
        configLayer(bgLayer, path: circlePath)
        sceneView.layer?.addSublayer(bgLayer)
        
        progressLayer.strokeColor = NSColor(0x7ec3ec).cgColor
        configLayer(progressLayer, path: circlePath)
        progressLayer.strokeEnd = 0
        sceneView.layer?.addSublayer(progressLayer)
    }
    
    func config(percent: CGFloat) {
        progressLayer.strokeEnd = percent
    }
    
    private func configLayer(_ layer: CAShapeLayer, path: NSBezierPath) {
        layer.path = path.cgPath
        layer.fillColor = NSColor.clear.cgColor
        layer.lineCap = .butt
        layer.lineWidth = 2
        layer.strokeStart = 0
        layer.strokeEnd = 1
    }
}
