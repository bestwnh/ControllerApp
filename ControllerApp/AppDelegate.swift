//
//  AppDelegate.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/8.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DeviceManager.shared.startMonitorDeviceChange()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

