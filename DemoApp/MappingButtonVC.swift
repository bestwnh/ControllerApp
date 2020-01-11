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

class MappingButtonVC: NSViewController {
    typealias MappingButtonAndList = (button: DeviceEvent.Mode.Button, list: [DeviceConfiguration.ButtonMapping])
    @IBOutlet weak var tableView: NSTableView!
    
    private var currentMapping: MappingButtonAndList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.reloadData()
        DeviceManager.shared.didChangeDevice = { _ in
            self.tableView.reloadData()
        }
        DeviceManager.shared.didTriggerEvent = { buttonEvent in
            guard let currentMapping = self.currentMapping,
                case let DeviceEvent.Mode.button(button) = buttonEvent.mode else { return }
            
            currentMapping.list.first(where: { $0.orgButton == currentMapping.button })?.mapToButton = button
            DeviceManager.shared.currentDevice?.configuration.buttonMappingList = currentMapping.list
            self.currentMapping = nil
            self.tableView.reloadData()
        }
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
