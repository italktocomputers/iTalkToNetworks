//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class PingSettingsViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var intervalTextbox: NSTextField!
    @IBOutlet weak var timeoutTextbox: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var maxTextbox: NSTextField!
    @IBOutlet weak var waitTextbox: NSTextField!
    @IBOutlet weak var ttlTextbox: NSTextField!
    @IBOutlet weak var packetSizeTextbox: NSTextField!
    @IBOutlet weak var sourceAddressTextbox: NSTextField!
    @IBOutlet weak var interfaceAddressTextbox: NSTextField!
    @IBOutlet weak var bypassRouteCheckbox: NSButton!
    @IBOutlet weak var noFragmentCheckbox: NSButton!
    @IBOutlet weak var supressLoopbackCheckbox: NSButton!

    override func viewDidLoad() {
        let pingInterval = Helper.getSetting(name: "pingInterval")
        let pingTimeout = Helper.getSetting(name: "pingTimeout")
        let pingMax = Helper.getSetting(name: "pingMax")
        let pingWait = Helper.getSetting(name: "pingWait")
        let pingTTL = Helper.getSetting(name: "pingTTL")
        let pingPacketSize = Helper.getSetting(name: "pingPacketSize")
        let pingSourceAddress = Helper.getSetting(name: "pingSourceAddress")
        let pingInterfaceAddress = Helper.getSetting(name: "pingInterfaceAddress")
        let pingBypassRoute = Helper.getSetting(name: "pingBypassRoute")
        let pingNoFragment = Helper.getSetting(name: "pingNoFragment")
        let pingSuppressLoopback = Helper.getSetting(name: "pingSuppressLoopback")

        Helper.initTextBox(val: pingInterval, box: intervalTextbox)
        Helper.initTextBox(val: pingTimeout, box: timeoutTextbox)
        Helper.initTextBox(val: pingMax, box: maxTextbox)
        Helper.initTextBox(val: pingWait, box: waitTextbox)
        Helper.initTextBox(val: pingTTL, box: ttlTextbox)
        Helper.initTextBox(val: pingPacketSize, box: packetSizeTextbox)
        Helper.initTextBox(val: pingSourceAddress, box: sourceAddressTextbox)
        Helper.initTextBox(val: pingInterfaceAddress, box: interfaceAddressTextbox)

        Helper.initCheckBox(val: pingBypassRoute, box: bypassRouteCheckbox)
        Helper.initCheckBox(val: pingNoFragment, box: noFragmentCheckbox)
        Helper.initCheckBox(val: pingSuppressLoopback, box: supressLoopbackCheckbox)
    }

    @IBAction func bypassRouteClick(_ sender: Any) {
        let state = bypassRouteCheckbox.state == NSControl.StateValue.on ? "on" : "off"
        Helper.saveSetting(key: "pingBypassRoute", value: state)
    }

    @IBAction func noFragmentClick(_ sender: Any) {
        let state = noFragmentCheckbox.state == NSControl.StateValue.on ? "on" : "off"
        Helper.saveSetting(key: "pingNoFragment", value: state)
    }

    @IBAction func suppressLoopbackClick(_ sender: Any) {
        let state = supressLoopbackCheckbox.state == NSControl.StateValue.on ? "on" : "off"
        Helper.saveSetting(key: "pingSuppressLoopback", value: state)
    }

    @IBAction func onIntervalChange(_ sender: Any) {
        Helper.saveSetting(key: "pingInterval", value: intervalTextbox.stringValue)
    }

    @IBAction func onTimeoutChange(_ sender: Any) {
        Helper.saveSetting(key: "pingTimeout", value: timeoutTextbox.stringValue)
    }

    @IBAction func onMaxChange(_ sender: Any) {
        Helper.saveSetting(key: "pingMax", value: maxTextbox.stringValue)
    }

    @IBAction func onWaitChange(_ sender: Any) {
        Helper.saveSetting(key: "pingWait", value: waitTextbox.stringValue)
    }

    @IBAction func onTTLChange(_ sender: Any) {
        Helper.saveSetting(key: "pingTTL", value: ttlTextbox.stringValue)
    }

    @IBAction func onPacketSizeChange(_ sender: Any) {
        Helper.saveSetting(key: "pingPacketSize", value: packetSizeTextbox.stringValue)
    }

    @IBAction func onSourceAddressChange(_ sender: Any) {
        Helper.saveSetting(key: "pingSourceAddress", value: sourceAddressTextbox.stringValue)
    }

    @IBAction func onInterfaceAddresshange(_ sender: Any) {
        Helper.saveSetting(key: "pingInterfaceAddress", value: interfaceAddressTextbox.stringValue)
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
