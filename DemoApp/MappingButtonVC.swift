//
//  MappingButtonVC.swift
//  DemoApp
//
//  Created by Galvin on 2020/1/6.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class MappingCell: NSTableCellView {
    var didClickMapButton: ()->() = {}
    
    @IBOutlet weak var mapButton: NSButton!
    @IBOutlet weak var mapToButtonTitleLabel: NSTextField!
    
    @IBAction func clickMapButton(_ sender: NSButton) {
        didClickMapButton()
    }
    
}

class MappingButtonVC: BaseVC {
    typealias MappingButtonAndList = (button: DeviceEvent.Mode.Button, list: [DeviceConfiguration.ButtonMapping])
    @IBOutlet weak var tableView: NSTableView!
    
    private var currentMapping: MappingButtonAndList?
    private var isMappingAllButtons: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.reloadData()

        NotificationObserver.addObserver(target: NotificationObserver.Target.currentDeviceChanged) { [weak self] (_) in
            self?.tableView.reloadData()
        }.handle(by: observerBag)
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceEventTriggered) { [weak self] (buttonEvent) in
            guard let self = self else { return }
            guard let buttonEvent = buttonEvent else { return }
            guard let currentMapping = self.currentMapping,
                case let DeviceEvent.Mode.button(button) = buttonEvent.mode, buttonEvent.value == 1 else { return }
            
            currentMapping.list.first(where: { $0.orgButton == currentMapping.button })?.mapToButton = button
            DeviceManager.shared.currentDevice?.configuration.buttonMappingList = currentMapping.list
            if self.isMappingAllButtons, let nextButton = DeviceEvent.Mode.Button(rawValue: currentMapping.button.rawValue + 1) {
                self.currentMapping?.button = nextButton
            } else {
                self.currentMapping = nil
            }
            self.tableView.reloadData()
            if self.currentMapping != nil {
                DeviceManager.shared.currentDevice?.configuration.resetButtonMapping()
            }
        }.handle(by: observerBag)
    }
    @IBAction func clickMapAllButtonsButton(_ sender: NSButton) {
        guard self.currentMapping == nil, !isMappingAllButtons else { return }
        isMappingAllButtons = true
        if isMappingAllButtons {
            self.currentMapping = (.a, DeviceManager.shared.currentDevice?.configuration.buttonMappingList ?? [])
            self.tableView.reloadData()
            DeviceManager.shared.currentDevice?.configuration.resetButtonMapping()
        }
    }
    @IBAction func clickResetMappingButton(_ sender: NSButton) {
        self.currentMapping = nil
        DeviceManager.shared.currentDevice?.configuration.resetButtonMapping()
        self.tableView.reloadData()
    }
    
}

extension MappingButtonVC: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DeviceEvent.Mode.Button.allCases.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as?  NSTableCellView,
            let tableColumn = tableColumn,
            let columnIndex = tableView.tableColumns.firstIndex(of: tableColumn) else { return nil }
        let orgButton = DeviceEvent.Mode.Button.allCases[row]
        let mapToButton = (self.currentMapping?.list ?? DeviceManager.shared.currentDevice?.configuration.buttonMappingList)?.first(where: { $0.orgButton == orgButton })?.mapToButton ?? orgButton
        switch columnIndex {
        case 0:
            cell.textField?.stringValue = "button: \(orgButton.title)"
        case 1:
            if let mappingCell = cell as? MappingCell {
                mappingCell.mapToButtonTitleLabel.stringValue = "\(mapToButton.title)"
                if orgButton == currentMapping?.button {
                    mappingCell.mapButton.title = "Cancel"
                } else {
                    mappingCell.mapButton.title = "Map"
                }
                mappingCell.didClickMapButton = { [weak self] in
                    guard let self = self else { return }
                    self.isMappingAllButtons = false
                    if let currentMapping = self.currentMapping {
                        if orgButton == currentMapping.button {
                            // cancel mapping
                            DeviceManager.shared.currentDevice?.configuration.buttonMappingList = currentMapping.list
                            self.currentMapping = nil
                        } else {
                            // change mapping button
                            self.currentMapping = (orgButton, currentMapping.list)
                        }
                        self.tableView.reloadData()
                    } else {
                        // start mapping button
                        self.currentMapping = (orgButton, DeviceManager.shared.currentDevice?.configuration.buttonMappingList ?? [])
                        self.tableView.reloadData()
                        DeviceManager.shared.currentDevice?.configuration.resetButtonMapping()
                    }
                }
            }
        default:
            break
        }
        return cell
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow >= 0 else { return }
        print("\(#function) row \(tableView.selectedRow)")
    }
}
