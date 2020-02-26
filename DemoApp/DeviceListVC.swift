//
//  DeviceListVC.swift
//  DemoApp
//
//  Created by Galvin on 2019/12/3.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import Cocoa

class DeviceListVC: BaseVC {

    @IBOutlet weak var tableView: NSTableView!
    private var deviceList: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.reloadData()
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceListChanged) { [weak self] (_) in
            guard let self = self else { return }
            self.deviceList = DeviceManager.shared.deviceList
            self.tableView.reloadData()
        }.handle(by: observerBag)
    }
    
}

extension DeviceListVC: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return deviceList.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as?  NSTableCellView else { return nil }
        let device = deviceList[row]
        cell.textField?.stringValue = "\(device.serialNumber): \(device.displayName)"
        return cell
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow >= 0 else { return }
        print("\(#function) row \(tableView.selectedRow)")
        DeviceManager.shared.selectedDevice(atIndex: tableView.selectedRow)
    }
}

