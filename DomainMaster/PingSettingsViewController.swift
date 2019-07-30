//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class PingSettingsViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var intervalTextbox: NSTextField!
    @IBOutlet weak var timeoutTextbox: NSTextField!
    //@IBOutlet weak var ipv4Checkbox: NSButton!
    //@IBOutlet weak var ipv6Checkbox: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var maxTextbox: NSTextField!

    override func viewDidLoad() {
        //let pingIpv4 = Helper.getSetting(name: "pingIpv4")
        //let pingIpv6 = Helper.getSetting(name: "pingIpv6")
        let pingInterval = Helper.getSetting(name: "pingInterval")
        let pingTimeout = Helper.getSetting(name: "pingTimeout")
        let pingMax = Helper.getSetting(name: "pingMax")

        Helper.initTextBox(val: pingInterval, box: intervalTextbox)
        Helper.initTextBox(val: pingTimeout, box: timeoutTextbox)
        Helper.initTextBox(val: pingMax, box: maxTextbox)
        //Helper.initCheckBox(val: pingIpv4, box: ipv4Checkbox)
        //Helper.initCheckBox(val: pingIpv6, box: ipv6Checkbox)
    }

    @IBAction func ipv4Click(_ sender: Any) {
        //let state = ipv4Checkbox.state == NSControl.StateValue.on ? "on" : "off"
        //Helper.saveSetting(key: "pingIpv4", value: state)
    }

    @IBAction func ipv6Click(_ sender: Any) {
        //let state = ipv6Checkbox.state == NSControl.StateValue.on ? "on" : "off"
        //Helper.saveSetting(key: "pingIpv6", value: state)
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
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
