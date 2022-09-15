//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class TraceRouteSettingsViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var waitTextBox: NSTextField!
    @IBOutlet weak var sourceAddressTextBox: NSTextField!
    @IBOutlet weak var portTextBox: NSTextField!
    @IBOutlet weak var maxHopsTextBox: NSTextField!
    @IBOutlet weak var numberOfProbesTextBox: NSTextField!
    @IBOutlet weak var typeOfServiceTextBox: NSTextField!
    @IBOutlet weak var bypassRouteTableCheckBox: NSButton!
    
    var errorOnClose = false
    
    override func viewDidLoad() {
        let wait = Helper.getSetting(name: "traceWait")
        let sourceAddress = Helper.getSetting(name: "traceSourceAddress")
        let port = Helper.getSetting(name: "tracePort")
        let maxHops = Helper.getSetting(name: "traceMaxHops")
        let numberOfProbes = Helper.getSetting(name: "traceNumberOfProbes")
        let typeOfService = Helper.getSetting(name: "traceTypeOfService")
        let bypassRouteTable = Helper.getSetting(name: "traceBypassRouteTable")
        
        Helper.initTextBox(val: wait, box: waitTextBox)
        Helper.initTextBox(val: sourceAddress, box: sourceAddressTextBox)
        Helper.initTextBox(val: port, box: portTextBox)
        Helper.initTextBox(val: maxHops, box: maxHopsTextBox)
        Helper.initTextBox(val: numberOfProbes, box: numberOfProbesTextBox)
        Helper.initTextBox(val: typeOfService, box: typeOfServiceTextBox)
        Helper.initCheckBox(val: bypassRouteTable, box: bypassRouteTableCheckBox)
    }
    
    @IBAction func onWaitChange(_ sender: Any) {
        if Helper.isNumeric(str: waitTextBox.stringValue) {
            errorOnClose = false
            Helper.saveSetting(key: "traceWait", value: waitTextBox.stringValue)
        }
        else {
            errorOnClose = true
            if let value = Helper.getDefaultSettings(index: "traceWait") {
                waitTextBox.stringValue = value
            }
            
            Helper.showIntegerOnlyPopover(view: self, sender: sender)
        }
    }
    
    @IBAction func onSourceAddressChange(_ sender: Any) {
        if Helper.isIpAddress(str: sourceAddressTextBox.stringValue) {
            errorOnClose = false
            Helper.saveSetting(key: "traceSourceAddress", value: sourceAddressTextBox.stringValue)
        }
        else {
            errorOnClose = true
            if let value = Helper.getDefaultSettings(index: "traceSourceAddress") {
                sourceAddressTextBox.stringValue = value
            }
            
            Helper.showIntegerOnlyPopover(view: self, sender: sender)
        }
    }
    
    @IBAction func onPortChange(_ sender: Any) {
        if Helper.isNumeric(str: portTextBox.stringValue) {
            errorOnClose = false
            Helper.saveSetting(key: "tracePort", value: portTextBox.stringValue)
        }
        else {
            errorOnClose = true
            if let value = Helper.getDefaultSettings(index: "tracePort") {
                portTextBox.stringValue = value
            }
            
            Helper.showIntegerOnlyPopover(view: self, sender: sender)
        }
    }
    
    @IBAction func onMaxHopsChange(_ sender: Any) {
        if Helper.isNumeric(str: maxHopsTextBox.stringValue) {
            errorOnClose = false
            Helper.saveSetting(key: "traceMaxHops", value: maxHopsTextBox.stringValue)
        }
        else {
            errorOnClose = true
            if let value = Helper.getDefaultSettings(index: "traceMaxHops") {
                maxHopsTextBox.stringValue = value
            }
            
            Helper.showIntegerOnlyPopover(view: self, sender: sender)
        }
    }
    
    @IBAction func onNumberOfProbesChange(_ sender: Any) {
        if Helper.isNumeric(str: numberOfProbesTextBox.stringValue) {
            errorOnClose = false
            Helper.saveSetting(key: "traceNumberOfProbes", value: numberOfProbesTextBox.stringValue)
        }
        else {
            errorOnClose = true
            if let value = Helper.getDefaultSettings(index: "traceNumberOfProbes") {
                numberOfProbesTextBox.stringValue = value
            }
            
            Helper.showIntegerOnlyPopover(view: self, sender: sender)
        }
    }
    
    @IBAction func onTypeOfServiceChange(_ sender: Any) {
        if Helper.isNumeric(str: typeOfServiceTextBox.stringValue) {
            errorOnClose = false
            Helper.saveSetting(key: "traceTypeOfService", value: typeOfServiceTextBox.stringValue)
        }
        else {
            errorOnClose = true
            if let value = Helper.getDefaultSettings(index: "traceTypeOfService") {
                typeOfServiceTextBox.stringValue = value
            }
            
            Helper.showIntegerOnlyPopover(view: self, sender: sender)
        }
    }
    
    @IBAction func byPassRoutingTableClick(_ sender: Any) {
        let state = bypassRouteTableCheckBox.state == NSControl.StateValue.on ? "on" : "off"
        Helper.saveSetting(key: "traceBypassRouteTable", value: state)
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.makeFirstResponder(sender)
        
        if errorOnClose == false {
            self.dismiss(self)
        }
        else {
            errorOnClose = false
        }
    }
}
