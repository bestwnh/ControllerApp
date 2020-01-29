//
//  ViewController.swift
//  DemoApp
//
//  Created by Galvin on 2019/11/17.
//  Copyright © 2019 GalvinLi. All rights reserved.
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
        layer?.borderColor = .white
        layer?.borderWidth = 1
        layer?.backgroundColor = NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0).cgColor
    }
    override func draw(_ dirtyRect: NSRect) {
        let canvasSize = dirtyRect.size
        let pointWidth: CGFloat = 4
        let validAreaColor = NSColor(red: 0.28, green: 0.55, blue: 0.21, alpha: 1.0)
        let valuePercent: CGFloat = (CGFloat(self.deadzone) / 32768 * 100).rounded() * 0.01 // keep two decimal number to prevent the incorrect tiny space between two area
        let deadzoneColor = NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        let stickPointColor = NSColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        let shadowPointColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.6)

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
}

class ViewController: BaseVC {
    var device: Device?
    
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var swapSticksButton: NSButton!
    
    
    @IBOutlet weak var leftStickInvertX: NSButton!
    @IBOutlet weak var leftStickInvertY: NSButton!
    @IBOutlet weak var leftStickNormalize: NSButton!
    @IBOutlet weak var leftStickLinked: NSButton!
    @IBOutlet weak var leftDeadzoneSlider: NSSlider!
    @IBOutlet weak var leftCanvasView: StickDeadzoneView!
    
    @IBOutlet weak var rightStickInvertX: NSButton!
    @IBOutlet weak var rightStickInvertY: NSButton!
    @IBOutlet weak var rightStickNormalize: NSButton!
    @IBOutlet weak var rightStickLinked: NSButton!
    @IBOutlet weak var rightDeadzoneSlider: NSSlider!
    @IBOutlet weak var rightCanvasView: StickDeadzoneView!
    
    lazy var buttons: [NSButton] = [swapSticksButton, leftStickInvertX, leftStickInvertY, rightStickInvertX, rightStickInvertY, leftStickNormalize, leftStickLinked, rightStickNormalize, rightStickLinked]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        output("App start")
        
        buttons.forEach{ $0.isEnabled = false }
        leftDeadzoneSlider.maxValue = 32767
        rightDeadzoneSlider.maxValue = 32767
        DeviceManager.shared.startMonitorDeviceChange()
        
        Notification.addObserver(target: Notification.Target.deviceEventTriggered) { [weak self] (buttonEvent) in
            guard let self = self else { return }
            guard let buttonEvent = buttonEvent else { return }
            switch buttonEvent.mode {
            case .axis(.leftStickX):
                self.updateLeftStickDeadzoneView(x: CGFloat(buttonEvent.value))
            case .axis(.leftStickY):
                self.updateLeftStickDeadzoneView(y: CGFloat(buttonEvent.value))
            case .axis(.rightStickX):
                self.updateRightStickDeadzoneView(x: CGFloat(buttonEvent.value))
            case .axis(.rightStickY):
                self.updateRightStickDeadzoneView(y: CGFloat(buttonEvent.value))
            default: break
            }
        }.handle(by: observerBag)
        Notification.addObserver(target: Notification.Target.deviceChanged) { [weak self] (_) in
            guard let self = self else { return }
            self.handleDeviceChanged()
        }.handle(by: observerBag)
    }
    
    func handleDeviceChanged() {
        if let device = DeviceManager.shared.currentDevice {
            output("binded device: \(device.displayName)")
            
            self.device = device
            print(device.configuration)
            swapSticksButton.state = device.configuration.swapSticks ? .on : .off
            leftStickInvertX.state = device.configuration.invertLeftX ? .on : .off
            leftStickInvertY.state = device.configuration.invertLeftY ? .on : .off
            rightStickInvertX.state = device.configuration.invertRightX ? .on : .off
            rightStickInvertY.state = device.configuration.invertRightY ? .on : .off
            leftStickLinked.state = device.configuration.linkedLeft ? .on : .off
            rightStickLinked.state = device.configuration.linkedRight ? .on : .off
            leftStickNormalize.state = device.configuration.normalizeLeft ? .on : .off
            rightStickNormalize.state = device.configuration.normalizeRight ? .on : .off
            leftDeadzoneSlider.integerValue = device.configuration.deadzoneLeft
            rightDeadzoneSlider.integerValue = device.configuration.deadzoneRight
            
            buttons.forEach{ $0.isEnabled = true }
            leftDeadzoneSlider.isEnabled = true
            rightDeadzoneSlider.isEnabled = true

        } else {
            self.device = nil
            buttons.forEach{ $0.isEnabled = false }
            leftDeadzoneSlider.isEnabled = false
            rightDeadzoneSlider.isEnabled = false
        }
        updateLeftStickDeadzoneView()
        updateRightStickDeadzoneView()
    }
    
    func output(_ string: String) {
        self.textView.string = string + "\n" + self.textView.string
    }
    
    @IBAction func tapSwapSticksButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.swapSticks = sender.state.boolValue
        }
    }
    
    @IBAction func tapLeftStickInvertXButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertLeftX = sender.state.boolValue
        }
    }
    
    @IBAction func tapLeftStickInvertYButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertLeftY = sender.state.boolValue
        }
    }
    
    @IBAction func tapLeftStickNormalizeButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.normalizeLeft = sender.state.boolValue
        }
        updateLeftStickDeadzoneView()
    }
    
    @IBAction func tapLeftStickLinkedButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.linkedLeft = sender.state.boolValue
        }
        updateLeftStickDeadzoneView()
    }
    
    @IBAction func tapRightStickInvertXButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertRightX = sender.state.boolValue
        }
    }
    
    @IBAction func tapRightStickInvertYButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.invertRightY = sender.state.boolValue
        }
    }
    
    @IBAction func tapRightStickNormalizeButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.normalizeRight = sender.state.boolValue
        }
        updateRightStickDeadzoneView()
    }
    
    @IBAction func tapRightStickLinkedButton(_ sender: NSButton) {
        if let device = self.device {
            device.configuration.linkedRight = sender.state.boolValue
        }
        updateRightStickDeadzoneView()
    }
    @IBAction func changeLeftDeadzoneSlider(_ sender: NSSlider) {
        if let device = self.device {
            device.configuration.deadzoneLeft = sender.integerValue
        }
        updateLeftStickDeadzoneView()
    }
    @IBAction func changeRightDeadzoneSlider(_ sender: NSSlider) {
        if let device = self.device {
            device.configuration.deadzoneRight = sender.integerValue
        }
        updateRightStickDeadzoneView()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func updateLeftStickDeadzoneView(x: CGFloat? = nil, y: CGFloat? = nil) {
        leftCanvasView.config(deadzone: leftDeadzoneSlider.integerValue,
                              isLinked: leftStickLinked.state.boolValue,
                              isNormalize: leftStickNormalize.state.boolValue,
                              x: x,
                              y: y)
    }
    private func updateRightStickDeadzoneView(x: CGFloat? = nil, y: CGFloat? = nil) {
        rightCanvasView.config(deadzone: rightDeadzoneSlider.integerValue,
                               isLinked: rightStickLinked.state.boolValue,
                               isNormalize: rightStickNormalize.state.boolValue,
                               x: x,
                               y: y)
    }
}

extension NSControl.StateValue {
    
    var boolValue: Bool {
        switch self {
        case .on:
            return true
        default:
            return false
        }
    }
}
