//
//  Notification.swift
//  DemoApp
//
//  Created by Galvin on 2020/1/22.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Foundation

struct ObserverTarget<A: Codable> {
    let name: NSNotification.Name
    init(name: String) {
        self.name = NSNotification.Name(name)
    }
}

extension ObserverTarget {
    func parse(userInfo: [AnyHashable: Any]?) -> A? {
        guard let userInfo = userInfo else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            return try JSONDecoder().decode(A.self, from: data)
        } catch {
            return nil
        }
    }
    func userInfo(param: A?) -> [AnyHashable: Any]? {
        do {
            let data = try JSONEncoder().encode(param)
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
}

class ObserverBag {
    private var observers: [NSObjectProtocol] = []
    func insert(_ observer: NSObjectProtocol) {
        observers.append(observer)
    }
    func removeAll() {
        observers.forEach{ NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
    }
}
extension NSObjectProtocol {
    func handle(by bag: ObserverBag) {
        bag.insert(self)
    }
}

class NotificationObserver {
    struct Target {
        struct Nil: Codable {}
    }
    static func addObserver<A>(target: ObserverTarget<A>, callback: @escaping (A?)->()) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: target.name, object: nil, queue: .main) { (notification) in
            callback(target.parse(userInfo: notification.userInfo))
        }
    }
    static func addDistributedObserver<A>(target: ObserverTarget<A>, callback: @escaping (A?)->()) -> NSObjectProtocol {
        return DistributedNotificationCenter.default.addObserver(forName: target.name, object: nil, queue: .main) { (notification) in
            callback(target.parse(userInfo: notification.userInfo))
        }
    }
    static func post<A>(target: ObserverTarget<A>, param: A? = nil) {
        NotificationCenter.default.post(name: target.name, object: nil, userInfo: target.userInfo(param: param))
    }
}
