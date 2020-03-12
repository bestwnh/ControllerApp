//
//  NSButtonExtension.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/10.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

extension NSButton {
    var boolState: Bool {
        set { state = newValue ? .on : .off }
        get { return state == .on }
    }
}
