//
//  UserDefaultManager.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/15.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Foundation

struct UserSetting: Codable {
    enum DisplayMode: Int, Codable {
        case bySystem
        case light
        case dark
    }
    static let userDefaultKey = "UserSetting"
    private var _displayMode: DisplayMode! = .bySystem
    private var _shouldHighlightEvent: Bool! = true
    
    var displayMode: DisplayMode {
        set { _displayMode = newValue }
        get { _displayMode ?? .bySystem }
    }
    
    var shouldHighlightEvent: Bool {
        set { _shouldHighlightEvent = newValue }
        get { _shouldHighlightEvent ?? true }
    }
}

class UserDefaultManager {
    static let shared = UserDefaultManager()
    private init() {
        if let data = UserDefaults.standard.data(forKey: UserSetting.userDefaultKey),
            let userSetting = try? JSONDecoder().decode(UserSetting.self, from: data) {
            self.userSetting = userSetting
        } else {
            self.userSetting = .init()
        }
    }
    
    var userSetting: UserSetting {
        didSet {
            if let data = try? JSONEncoder().encode(userSetting) {
                UserDefaults.standard.set(data, forKey: UserSetting.userDefaultKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
}
