//
//  CollectionExtension.swift
//  ControllerApp
//
//  Created by Galvin on 2019/12/2.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
