//
//  SliderCell.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/9.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class SliderCell: NSSliderCell {

    override func drawKnob(_ knobRect: NSRect) {
        let bg = NSBezierPath(roundedRect: knobRect,
                              xRadius: knobRect.width * 0.5,
                              yRadius: knobRect.height * 0.5)
        NSColor(0xfafeff).setFill()
        bg.fill()
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        let orgRect = super.knobRect(flipped: flipped)
        let knobRadius: CGFloat = 4
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let rect = NSRect(x: (orgRect.minX + 3) + value * (orgRect.width - 12),
                          y: orgRect.midY - knobRadius,
                          width: knobRadius * 2,
                          height: knobRadius * 2)
        return rect
    }
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        var rect = rect
        rect.size.height = 4
        rect.size.width += 2
        let barRadius: CGFloat = 2
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let finalWidth: CGFloat = value * (self.controlView!.bounds.size.width - 12) + 4
        var leftRect = rect
        leftRect.size.width = finalWidth
        let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor(0x1c5773).setFill()
        bg.fill()
        let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        NSColor(0x7ec3ec).setFill()
        active.fill()
    }
    
    
}
