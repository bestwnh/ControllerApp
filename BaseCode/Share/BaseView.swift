//
//  BaseView.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/14.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class BaseView: NSView {
    
    @IBInspectable var ib_BackgroundColor: NSColor? {
        didSet {
            wantsLayer = true
            updateLayer()
        }
    }
    
    override func updateLayer() {
        super.updateLayer()
        
        if let bgColor = ib_BackgroundColor {
            layer?.backgroundColor = bgColor.cgColor
        }
    }
    
}
