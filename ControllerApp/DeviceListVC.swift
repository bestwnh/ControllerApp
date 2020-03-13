//
//  DeviceListVC.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/10.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class DeviceCell: NSTableCellView {
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var snLabel: NSTextField!
    
}

class DeviceListVC: BaseVC {

    @IBOutlet weak var tableView: NSTableView!
    private var deviceList: [Device] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.selectionHighlightStyle = .none
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
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? DeviceCell else { return nil }
        let device = deviceList[row]
        cell.nameLabel.stringValue = device.displayName
        cell.snLabel.stringValue = "SN: \(device.serialNumber)"
        return cell
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow >= 0 else { return }
        print("\(#function) row \(tableView.selectedRow)")
        DeviceManager.shared.selectedDevice(atIndex: tableView.selectedRow)
    }
}
