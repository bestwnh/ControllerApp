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
    @IBOutlet weak var downloadDriverView: NSStackView!
    @IBOutlet weak var downloadDriverButton: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.selectionHighlightStyle = .none
        tableView.reloadData()
        tableView.target = self
        tableView.action = #selector(clickTableViewRow)
        updateDownloadDriverView()
        downloadDriverButton.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickDownloadDriverButton)))
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceListChanged) { [weak self] (_) in
            guard let self = self else { return }
            self.deviceList = DeviceManager.shared.deviceList
            self.tableView.reloadData()
            self.updateDownloadDriverView()
        }.handle(by: observerBag)
    }
    
    @objc
    private func clickTableViewRow() {
        DeviceManager.shared.selectedDevice(atIndex: tableView.clickedRow)
        tableView.reloadData()
    }
    
    @objc
    private func clickDownloadDriverButton(_ sender: NSClickGestureRecognizer) {
        DriverHelper.openDownloadPage()
    }
    
    private func updateDownloadDriverView() {
        downloadDriverView.show(when: !DriverHelper.isDriverInstalled && deviceList.isEmpty)
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
        
        if DeviceManager.shared.currentDevice == device {
            cell.nameLabel.alphaValue = 1
            cell.alphaValue = 1
        } else {
            cell.nameLabel.alphaValue = 0.5
            cell.alphaValue = 0.3
        }
        return cell
    }
    
}
