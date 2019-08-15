//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class PingSettingsViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var countTextbox: NSTextField!
    @IBOutlet weak var waitTextbox: NSTextField!
    @IBOutlet weak var timeoutTextbox: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var ttlTextbox: NSTextField!
    @IBOutlet weak var interfaceAddressTextbox: NSTextField!
    @IBOutlet weak var sourceAddressTextbox: NSTextField!
    @IBOutlet weak var preloadTextbox: NSTextField!
    @IBOutlet weak var packetSizeTextbox: NSTextField!
    @IBOutlet weak var maskTextbox: NSTextField!
    @IBOutlet weak var ipsecPolicyTextbox: NSTextField!
    @IBOutlet weak var sweepMaxSizeTextbox: NSTextField!
    @IBOutlet weak var sweepMinSizeTextbox: NSTextField!
    @IBOutlet weak var sweepIncSizeTextbox: NSTextField!
    @IBOutlet weak var patternTextbox: NSTextField!
    @IBOutlet weak var tosTextbox: NSTextField!
    @IBOutlet weak var bypassRouteCheckbox: NSButton!
    @IBOutlet weak var noFragmentCheckbox: NSButton!
    @IBOutlet weak var supressLoopbackCheckbox: NSButton!
    @IBOutlet weak var floodPingCheckbox: NSButton!

    
    @IBOutlet weak var countFormatter: NumberFormatter!
    
    override func viewDidLoad() {
        let pingCount = Helper.getSetting(name: "pingCount")
        let pingWait = Helper.getSetting(name: "pingWait")
        let pingTimeout = Helper.getSetting(name: "pingTimeout")
        let pingTTL = Helper.getSetting(name: "pingTTL")
        let pingInterfaceAddress = Helper.getSetting(name: "pingInterfaceAddress")
        let pingSourceAddress = Helper.getSetting(name: "pingSourceAddress")
        let pingPreload = Helper.getSetting(name: "pingPreload")
        let pingPacketSize = Helper.getSetting(name: "pingPacketSize")
        let pingMask = Helper.getSetting(name: "pingMask")
        let pingIpsecPolicy = Helper.getSetting(name: "pingIpsecPolicy")
        let pingSweepMaxSize = Helper.getSetting(name: "pingSweepMaxSize")
        let pingSweepMinSize = Helper.getSetting(name: "pingSweepMinSize")
        let pingSweepIncSize = Helper.getSetting(name: "pingSweepIncSize")
        let pingPattern = Helper.getSetting(name: "pingPattern")
        let pingTos = Helper.getSetting(name: "pingTos")
        let pingBypassRoute = Helper.getSetting(name: "pingBypassRoute")
        let pingNoFragment = Helper.getSetting(name: "pingNoFragment")
        let pingSuppressLoopback = Helper.getSetting(name: "pingSuppressLoopback")
        let pingFlood = Helper.getSetting(name: "pingFlood")

        Helper.initTextBox(val: pingCount, box: countTextbox)
        Helper.initTextBox(val: pingWait, box: waitTextbox)
        Helper.initTextBox(val: pingTimeout, box: timeoutTextbox)
        Helper.initTextBox(val: pingTTL, box: ttlTextbox)
        Helper.initTextBox(val: pingInterfaceAddress, box: interfaceAddressTextbox)
        Helper.initTextBox(val: pingSourceAddress, box: sourceAddressTextbox)
        Helper.initTextBox(val: pingPreload, box: preloadTextbox)
        Helper.initTextBox(val: pingPacketSize, box: packetSizeTextbox)
        Helper.initTextBox(val: pingMask, box: maskTextbox)
        Helper.initTextBox(val: pingIpsecPolicy, box: ipsecPolicyTextbox)
        Helper.initTextBox(val: pingSweepMaxSize, box: sweepMaxSizeTextbox)
        Helper.initTextBox(val: pingSweepMinSize, box: sweepMinSizeTextbox)
        Helper.initTextBox(val: pingSweepIncSize, box: sweepIncSizeTextbox)
        Helper.initTextBox(val: pingPattern, box: patternTextbox)
        Helper.initTextBox(val: pingTos, box: tosTextbox)

        Helper.initCheckBox(val: pingBypassRoute, box: bypassRouteCheckbox)
        Helper.initCheckBox(val: pingNoFragment, box: noFragmentCheckbox)
        Helper.initCheckBox(val: pingSuppressLoopback, box: supressLoopbackCheckbox)
        Helper.initCheckBox(val: pingFlood, box: floodPingCheckbox)
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

    @IBAction func floodPingClick(_ sender: Any) {
        let state = floodPingCheckbox.state == NSControl.StateValue.on ? "on" : "off"
        Helper.saveSetting(key: "pingFlood", value: state)
    }

    @IBAction func onCountChange(_ sender: Any) {
        if countTextbox.stringValue.contains("0987654321") {
            Helper.saveSetting(key: "pingCount", value: countTextbox.stringValue)
        }
        else {
            let sb = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            if let vc: NSViewController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("error_integer_only")) as? NSViewController {

                self.present(vc, asPopoverRelativeTo: ((sender as AnyObject).bounds)!, of: sender as! NSView, preferredEdge: NSRectEdge.maxX, behavior: NSPopover.Behavior.transient)
            }
        }

    }

    @IBAction func onTimeoutChange(_ sender: Any) {
        Helper.saveSetting(key: "pingTimeout", value: timeoutTextbox.stringValue)
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

    @IBAction func onInterfaceAddressChange(_ sender: Any) {
        Helper.saveSetting(key: "pingInterfaceAddress", value: interfaceAddressTextbox.stringValue)
    }

    @IBAction func onPreloadChange(_ sender: Any) {
        Helper.saveSetting(key: "pingPreload", value: preloadTextbox.stringValue)
    }

    @IBAction func onMaskChange(_ sender: Any) {
        Helper.saveSetting(key: "pingMask", value: maskTextbox.stringValue)
    }

    @IBAction func onIpsecPolicyChange(_ sender: Any) {
        Helper.saveSetting(key: "pingIpsecPolicy", value: ipsecPolicyTextbox.stringValue)
    }

    @IBAction func onSweepMaxSizeChange(_ sender: Any) {
        Helper.saveSetting(key: "pingSweepMaxSize", value: sweepMaxSizeTextbox.stringValue)
    }

    @IBAction func onSweepMinSizeChange(_ sender: Any) {
        Helper.saveSetting(key: "pingSweepMinSize", value: sweepMinSizeTextbox.stringValue)
    }

    @IBAction func onSweeIncSizeChange(_ sender: Any) {
        Helper.saveSetting(key: "pingSweepIncSize", value: sweepIncSizeTextbox.stringValue)
    }

    @IBAction func onPatternChange(_ sender: Any) {
        Helper.saveSetting(key: "pingPattern", value: patternTextbox.stringValue)
    }

    @IBAction func onTosChange(_ sender: Any) {
        Helper.saveSetting(key: "pingTos", value: tosTextbox.stringValue)
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
