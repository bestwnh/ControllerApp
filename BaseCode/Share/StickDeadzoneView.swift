//
//  StickDeadzoneView.swift
//  DemoApp
//
//  Created by Galvin on 2020/1/29.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class StickDeadzoneView: NSView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    private var deadzone: Int = 0
    private var isLinked: Bool = false
    private var isNormalize: Bool = false
    private var x: CGFloat = 0
    private var y: CGFloat = 0

    private func initView() {
        wantsLayer = true
        layer?.borderColor = NSColor(0x7ec3ec).cgColor
        layer?.borderWidth = 1
        layer?.backgroundColor = NSColor(0x1E1E1E).cgColor
    }
    override func draw(_ dirtyRect: NSRect) {
        let canvasSize = dirtyRect.size
        let pointWidth: CGFloat = 4
//        let validAreaColor = NSColor(0x478C36)
        let validAreaColor = NSColor(0x06415e)

        let valuePercent: CGFloat = (CGFloat(self.deadzone) / 32768 * 100).rounded() * 0.01 // keep two decimal number to prevent the incorrect tiny space between two area
        let deadzoneColor = NSColor(0x1E1E1E)
        let stickPointColor = NSColor(0xFFFF00)
        let shadowPointColor = NSColor(0xFFFFFF).withAlphaComponent(0.6)

        let bgScale: CGFloat = 1.15
        let bgPath = NSBezierPath(ovalIn: .init(x: canvasSize.width * (1 - bgScale) * 0.5,
                                                y: canvasSize.height * (1 - bgScale) * 0.5,
                                                width: canvasSize.width * bgScale,
                                                height: canvasSize.height * bgScale))
        validAreaColor.set()
        bgPath.fill()
        
        let centerAreaSize = CGSize(width: min(canvasSize.width * valuePercent, canvasSize.width - pointWidth * 2),
                                    height: min(canvasSize.height * valuePercent, canvasSize.height - pointWidth * 2))
        let centerArea = CGRect(origin: .init(x: (canvasSize.width - centerAreaSize.width) * 0.5,
                                              y: (canvasSize.height - centerAreaSize.height) * 0.5),
                                size: centerAreaSize)
        draw(rect: centerArea, with: deadzoneColor)
        
        let centerPath = NSBezierPath(ovalIn: .init(x: centerArea.midX - pointWidth * 0.5,
                                                    y: centerArea.midY - pointWidth * 0.5,
                                                    width: pointWidth,
                                                    height: pointWidth))
        validAreaColor.set()
        centerPath.fill()
        
        if !isLinked {
            let topArea = CGRect(x: centerArea.minX,
                                 y: centerArea.maxY,
                                 width: centerArea.width,
                                 height: centerArea.minY)
            draw(rect: topArea, with: deadzoneColor)
            
            let bottomArea = CGRect(x: centerArea.minX,
                                    y: 0,
                                    width: centerArea.width,
                                    height: centerArea.minY)
            draw(rect: bottomArea, with: deadzoneColor)
            
            let leftArea = CGRect(x: 0,
                                  y: centerArea.minY,
                                  width: centerArea.minX,
                                  height: centerArea.height)
            draw(rect: leftArea, with: deadzoneColor)
            
            let rightArea = CGRect(x: centerArea.maxX,
                                   y: centerArea.minY,
                                   width: centerArea.minX,
                                   height: centerArea.height)
            draw(rect: rightArea, with: deadzoneColor)
            
            let topLine = CGRect(x: topArea.midX - pointWidth * 0.5,
                                 y: topArea.minY,
                                 width: pointWidth,
                                 height: topArea.height)
            draw(rect: topLine, with: validAreaColor)
            
            let bottomLine = CGRect(x: bottomArea.midX - pointWidth * 0.5,
                                    y: bottomArea.minY,
                                    width: pointWidth,
                                    height: bottomArea.height)
            draw(rect: bottomLine, with: validAreaColor)
            
            let leftLine = CGRect(x: leftArea.minX,
                                  y: leftArea.midY - pointWidth * 0.5,
                                  width: leftArea.width,
                                  height: pointWidth)
            draw(rect: leftLine, with: validAreaColor)
            
            let rightLine = CGRect(x: rightArea.minX,
                                   y: rightArea.midY - pointWidth * 0.5,
                                   width: rightArea.width,
                                   height: pointWidth)
            draw(rect: rightLine, with: validAreaColor)
        }
        
        func limitedRectInCanvas(_ rect: CGRect) -> CGRect {
            return CGRect(x: max(min(rect.origin.x, canvasSize.width - rect.width), 0),
                          y: max(min(rect.origin.y, canvasSize.height - rect.height), 0),
                          width: rect.width,
                          height: rect.height)
        }
        let stickPoint = CGPoint(x: canvasSize.width * 0.5 * x,
                                 y: canvasSize.height * 0.5 * -y)
        if isNormalize {
            func normalize(position: CGFloat) -> CGFloat {
                if position > 0 {
                    return (abs(position) * (1 - valuePercent)) + (centerArea.midX * valuePercent) + 1
                } else if position < 0 {
                    return -((abs(position) * (1 - valuePercent)) + (centerArea.midX * valuePercent) + 1)
                } else {
                    return position
                }
            }
            
            let shadowPointRect = CGRect(x: normalize(position: stickPoint.x) + centerArea.midX - pointWidth * 0.5,
                                         y: normalize(position: stickPoint.y) + centerArea.midY - pointWidth * 0.5,
                                         width: pointWidth,
                                         height: pointWidth)
            let shadowPointPath = NSBezierPath(ovalIn: limitedRectInCanvas(shadowPointRect))
            shadowPointColor.set()
            shadowPointPath.fill()
        }
        
        let stickPointRect = CGRect(x: stickPoint.x + centerArea.midX - pointWidth * 0.5,
                                    y: stickPoint.y + centerArea.midY - pointWidth * 0.5,
                                    width: pointWidth,
                                    height: pointWidth)
        let stickPointPath = NSBezierPath(ovalIn: limitedRectInCanvas(stickPointRect))
        stickPointColor.set()
        stickPointPath.fill()
        
        
    }
    func draw(rect: CGRect, with color: NSColor) {
        let path = NSBezierPath(rect: rect)
        color.set()
        path.fill()
    }
    func config(deadzone: Int, isLinked: Bool, isNormalize: Bool, x: CGFloat? = nil, y: CGFloat? = nil) {
        self.deadzone = deadzone
        self.isLinked = isLinked
        self.isNormalize = isNormalize
        if let x = x {
            self.x = x
        }
        if let y = y {
            self.y = y
        }
        needsDisplay = true
    }
    func reset() {
        config(deadzone: 0, isLinked: false, isNormalize: false, x: 0, y: 0)
    }
}
