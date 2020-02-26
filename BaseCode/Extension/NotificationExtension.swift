//
//  NotificationExtension.swift
//  DemoApp
//
//  Created by Galvin on 2020/2/26.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Foundation

extension NotificationObserver.Target {
    static let deviceEventTriggered = ObserverTarget<DeviceEvent>(name: "deviceEventTriggered")
    static let currentDeviceChanged = ObserverTarget<Nil>(name: "currentDeviceChanged")
    static let deviceListChanged = ObserverTarget<Nil>(name: "deviceListChanged")
    static let uiModeChanged = ObserverTarget<Nil>(name: "AppleInterfaceThemeChangedNotification")
}
