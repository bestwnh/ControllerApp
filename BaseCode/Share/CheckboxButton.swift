//
//  CheckboxButton.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/10.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class CheckboxButton: NSButton {

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        updateStyle()
    }
    
    override var title: String {
        didSet {
            updateStyle()
        }
    }
    
    private func updateStyle() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 10.0
        
        if let color = NSColor(named: "MainText") {
        attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.baselineOffset: -2,
            ])}
    }
}
