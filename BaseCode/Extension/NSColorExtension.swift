//
//  NSColorExtension.swift
//  DemoApp
//
//  Created by Galvin on 2020/2/23.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

extension NSColor {
    
    /**
     Creates a color from an hex integer (e.g. 0x3498db).
     
     - parameter hex: A hexa-decimal UInt32 that represents a color.
     */
    @objc(hex:)
    convenience init(_ hex: UInt32) {
        let mask = 0x000000FF
        
        let rValue = Int(hex >> 16) & mask
        let gValue = Int(hex >> 8) & mask
        let bValue = Int(hex) & mask
        
        let red   = CGFloat(rValue) / 255
        let green = CGFloat(gValue) / 255
        let blue  = CGFloat(bValue) / 255
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
}
