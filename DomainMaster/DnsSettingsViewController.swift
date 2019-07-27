//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class DnsSettingsViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var iPv4: NSButton!
    @IBOutlet weak var iPv6: NSButton!
    @IBOutlet weak var rtA: NSButton!
    @IBOutlet weak var rtAAAA: NSButton!
    @IBOutlet weak var rtAlias: NSButton!
    @IBOutlet weak var rtCname: NSButton!
    @IBOutlet weak var rtMx: NSButton!
    @IBOutlet weak var rtNs: NSButton!
    @IBOutlet weak var rtPtr: NSButton!
    @IBOutlet weak var rtSoa: NSButton!
    @IBOutlet weak var rtSrv: NSButton!
    @IBOutlet weak var rtTxt: NSButton!
    @IBOutlet weak var rtAny: NSButton!
    @IBOutlet weak var dnsPort: NSTextField!
    @IBOutlet weak var dnsSource: NSTextField!
    @IBOutlet weak var dnsTimeout: NSTextField!
    
    override func viewDidLoad() {
        let selectedResourceType = Helper.getSetting(name: "resourceType")
        let iPv4Value = Helper.getSetting(name: "iPv4")
        let iPv6Value = Helper.getSetting(name: "iPv6")
        let dnsPortValue = Helper.getSetting(name: "dnsPort")
        let dnsSourceValue = Helper.getSetting(name: "dnsSource")
        let dnsTimeoutValue = Helper.getSetting(name: "dnsTimeout")
        
        switch selectedResourceType {
            case "A":
                rtA.state = NSControl.StateValue.on
            case "AAAA":
                rtAAAA.state = NSControl.StateValue.on
            case "ALIAS":
                rtAlias.state = NSControl.StateValue.on
            case "CNAME":
                rtCname.state = NSControl.StateValue.on
            case "MX":
                rtMx.state = NSControl.StateValue.on
            case "NS":
                rtNs.state = NSControl.StateValue.on
            case "PTR":
                rtPtr.state = NSControl.StateValue.on
            case "SOA":
                rtSoa.state = NSControl.StateValue.on
            case "SRV":
                rtSrv.state = NSControl.StateValue.on
            case "TXT":
                rtTxt.state = NSControl.StateValue.on
            default:
                rtAny.state = NSControl.StateValue.on
        }
        
        Helper.initTextBox(val: dnsPortValue, box: dnsPort)
        Helper.initTextBox(val: dnsSourceValue, box: dnsSource)
        Helper.initTextBox(val: dnsTimeoutValue, box: dnsTimeout)
        Helper.initCheckBox(val: iPv4Value, box: iPv4)
        Helper.initCheckBox(val: iPv6Value, box: iPv6)
    }
    
    func windowWillClose(_ notification: Notification) {
        
    }
    
    @IBAction func iPv4Click(_ sender: NSButton) {
        let state = iPv4.state == NSControl.StateValue.on ? "on" : "off"
        Helper.saveSetting(key: "iPv4", value: state)
    }
    
    @IBAction func iPv6Click(_ sender: NSButton) {
        let state = iPv6.state == NSControl.StateValue.on ? "on" : "off"
        Helper.saveSetting(key: "iPv6", value: state)
    }
    
    @IBAction func prClick(_ sender: Any) {
        /*
            https://developer.apple.com/library/mac/releasenotes/AppKit/RN-AppKitOlderNotes/
            To have the button work in a radio group, use the same -action for
            each NSButton instance, and have the same superview for each button.
            When these conditions are met, checking one button (by changing the
            -state to 1), will uncheck all other buttons (by setting their -state
            to 0)."
        */
        let box = sender as! NSButton
        print(box.title)
        Helper.saveSetting(key: "resourceType", value: box.title)
    }
    
    @IBAction func dnsPortChange(_ sender: NSTextField) {
        Helper.saveSetting(key: "dnsPort", value: dnsPort.stringValue)
    }
    
    @IBAction func dnsSourceChange(_ sender: NSTextField) {
        Helper.saveSetting(key: "dnsSource", value: dnsSource.stringValue)
    }
    
    @IBAction func dnsTimeoutChange(_ sender: NSTextField) {
        Helper.saveSetting(key: "dnsTimeout", value: dnsTimeout.stringValue)
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
