//
//  BaseVC.swift
//  DemoApp
//
//  Created by Galvin on 2020/1/22.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class BaseVC: NSViewController {
    lazy var observerBag = ObserverBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    deinit {
        observerBag.removeAll()
    }
}
