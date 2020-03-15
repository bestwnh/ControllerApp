//
//  MapButtonVC.swift
//  ControllerApp
//
//  Created by Galvin on 2020/3/11.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Cocoa

class MapButtonTableCell: NSTableCellView {
    typealias ConfigItem = (orginal: String, mapTo: String, isMapping: Bool)
    var didClickMapButton: ()->() = {}

    @IBOutlet weak var orginalButtonLabel: NSTextField!
    @IBOutlet weak var mapToButtonLabel: NSTextField!
    @IBOutlet weak var mapButton: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapButton.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickMapButton)))
    }
    
    @objc
    func clickMapButton(_ sender: NSClickGestureRecognizer) {
        didClickMapButton()
    }
    
    func config(item: ConfigItem) {
        orginalButtonLabel.stringValue = item.orginal
        mapToButtonLabel.stringValue = item.mapTo
        mapButton.stringValue = item.isMapping ? "Cancel" : "Map"
    }
}

class MapButtonVC: BaseVC {
    typealias MappingButtonAndList = (button: DeviceEvent.Mode.Button, list: [DeviceConfiguration.ButtonMapping])

    @IBOutlet weak var mapAllButton: NSView!
    @IBOutlet weak var resetButton: NSView!
    @IBOutlet weak var tableView: NSTableView!
    
    private var currentMapping: MappingButtonAndList?
    private var isMappingAllButtons: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapAllButton.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickMapAllButton)))
        resetButton.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickResetButton)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.selectionHighlightStyle = .none
        tableView.reloadData()
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.currentDeviceChanged) { [weak self] (_) in
            self?.tableView.reloadData()
            self?.tableView.scrollRowToVisible(0)
        }.handle(by: observerBag)
        
        NotificationObserver.addObserver(target: NotificationObserver.Target.deviceEventTriggered) { [weak self] (buttonEvent) in
            guard let self = self else { return }
            guard let buttonEvent = buttonEvent else { return }
            guard let currentMapping = self.currentMapping,
                case let DeviceEvent.Mode.button(button) = buttonEvent.mode,
                buttonEvent.value == 1 else { return }
            
            currentMapping.list.first(where: { $0.orgButton == currentMapping.button })?.mapToButton = button
            DeviceManager.shared.currentDevice?.configuration.buttonMappingList = currentMapping.list
            if self.isMappingAllButtons, let nextButton = DeviceEvent.Mode.Button(rawValue: currentMapping.button.rawValue + 1) {
                self.currentMapping?.button = nextButton
                self.tableView.reloadData()
                if let index = self.buttonList.firstIndex(where: { $0.rawValue == nextButton.rawValue }) {
                    self.tableView.scrollRowToVisible(index)
                }
            } else {
                self.currentMapping = nil
                self.tableView.reloadData()
            }
            if self.currentMapping != nil {
                DeviceManager.shared.currentDevice?.configuration.resetButtonMapping()
            }
        }.handle(by: observerBag)
    }
    
    @objc
    func clickMapAllButton(_ sender: NSClickGestureRecognizer) {
        guard self.currentMapping == nil, !isMappingAllButtons else { return }
        isMappingAllButtons = true
        self.currentMapping = (.a, DeviceManager.shared.currentDevice?.configuration.buttonMappingList ?? [])
        self.tableView.reloadData()
        self.tableView.scrollRowToVisible(0)
        DeviceManager.shared.currentDevice?.configuration.resetButtonMapping()
    }
    
    @objc
    func clickResetButton(_ sender: NSClickGestureRecognizer) {
        self.currentMapping = nil
        DeviceManager.shared.currentDevice?.configuration.resetButtonMapping()
        self.tableView.reloadData()
        self.tableView.scrollRowToVisible(0)
    }
    
    private let buttonList = DeviceEvent.Mode.Button.allCases
}

extension MapButtonVC: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return buttonList.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as?  MapButtonTableCell else { return nil }
        let orgButton = buttonList[row]
        let mapToButton = (self.currentMapping?.list ?? DeviceManager.shared.currentDevice?.configuration.buttonMappingList)?.first(where: { $0.orgButton == orgButton })?.mapToButton ?? orgButton
        
        cell.config(item: (
            orginal: "Button: \(orgButton.title)",
            mapTo: "\(mapToButton.title)",
            isMapping: orgButton == currentMapping?.button
        ))
        
        cell.didClickMapButton = { [weak self] in
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
        return cell
    }
}
