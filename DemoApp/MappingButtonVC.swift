//
//  MappingButtonVC.swift
//  DemoApp
//
//  Created by Galvin on 2020/1/6.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class MappingButtonVC: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.reloadData()
        
    }
    
}

extension MappingButtonVC: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DeviceEvent.Mode.Button.allCases.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as?  NSTableCellView else { return nil }
        let button = DeviceEvent.Mode.Button.allCases[row]
        cell.textField?.stringValue = "button: \(button.title)"
        return cell
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow >= 0 else { return }
        print("\(#function) row \(tableView.selectedRow)")
    }
}
