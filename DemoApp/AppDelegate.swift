//
//  AppDelegate.swift
//  DemoApp
//
//  Created by Galvin on 2019/11/17.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application
        DeviceManager.shared.startMonitorDeviceChange()

    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

