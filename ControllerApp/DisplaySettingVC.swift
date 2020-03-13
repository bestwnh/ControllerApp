//
//  DisplaySettingVC.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/13.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class DisplaySettingVC: BaseVC {
    enum DisplayMode {
        case bySystem
        case light
        case dark
    }
    @IBOutlet weak var displayModeView: NSView!
    @IBOutlet weak var bySystemButton: BaseView!
    @IBOutlet weak var lightButton: BaseView!
    @IBOutlet weak var darkButton: BaseView!
    @IBOutlet weak var line1: NSView!
    @IBOutlet weak var line2: NSView!
    
    var currentDisplayMode: DisplayMode = .bySystem {
        didSet {
            guard currentDisplayMode != oldValue else { return }
            
            if #available(OSX 10.14, *) {
                updateDisplayModeView()
                NotificationObserver.postDistributed(target: NotificationObserver.Target.DistributedNotification.uiModeChanged)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(OSX 10.14, *) {
            displayModeView.show()
            updateDisplayModeView()
            
            bySystemButton.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickBySystemButton)))
            lightButton.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickLightButton)))
            darkButton.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickDarkButton)))

        } else {
            displayModeView.hide()
        }
        
    }
    
    
}

private extension DisplaySettingVC {
    @objc
    func clickBySystemButton(_ sender: NSClickGestureRecognizer) {
        currentDisplayMode = .bySystem
    }
    @objc
    func clickLightButton(_ sender: NSClickGestureRecognizer) {
        currentDisplayMode = .light
    }
    @objc
    func clickDarkButton(_ sender: NSClickGestureRecognizer) {
        currentDisplayMode = .dark
    }
    
    @available(OSX 10.14, *)
    func updateDisplayModeView() {
        [bySystemButton, lightButton, darkButton].forEach{
            $0?.ib_BackgroundColor = .clear
            ($0?.subviews.first as? NSTextField)?.textColor = NSColor(named: "SegmentText")
        }
        switch currentDisplayMode {
        case .bySystem:
            NSApp.appearance = nil
            (bySystemButton.subviews.first as? NSTextField)?.textColor = NSColor(named: "SegmentSelectedText")
            bySystemButton.ib_BackgroundColor = NSColor(named: "SegmentSelectedBg")
            line1.hide()
            line2.show()
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
            (lightButton.subviews.first as? NSTextField)?.textColor = NSColor(named: "SegmentSelectedText")
            lightButton.ib_BackgroundColor = NSColor(named: "SegmentSelectedBg")
            line1.hide()
            line2.hide()
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
            (darkButton.subviews.first as? NSTextField)?.textColor = NSColor(named: "SegmentSelectedText")
            darkButton.ib_BackgroundColor = NSColor(named: "SegmentSelectedBg")
            line1.show()
            line2.hide()
        }
    }
}
