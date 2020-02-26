//
//  AppState.swift
//  DemoApp
//
//  Created by Galvin on 2020/2/26.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

final class AppState {
    static var isDarkMode: Bool {
        if #available(OSX 10.14, *) {
            if NSApp.effectiveAppearance == NSAppearance(named: .darkAqua) {
                return true
            }
        }
        return false
    }
}
