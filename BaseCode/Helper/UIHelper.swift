//
//  UIHelper.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/9.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

struct UIHelper {
    static func styleCheckboxButton(_ button: NSButton) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 10.0
        
        if let color = NSColor(named: "MainText") {
        button.attributedTitle = NSAttributedString(
            string: button.title,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: color
            ])}
    }
}
