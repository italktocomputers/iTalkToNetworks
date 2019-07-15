//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class PreferencesViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var iPv4: NSButton!
    @IBOutlet weak var iPv6: NSButton!
    @IBOutlet weak var rcA: NSButton!
    @IBOutlet weak var rcAAAA: NSButton!
    @IBOutlet weak var rcAlias: NSButton!
    @IBOutlet weak var rcCname: NSButton!
    @IBOutlet weak var rcMx: NSButton!
    @IBOutlet weak var rcNs: NSButton!
    @IBOutlet weak var rcPtr: NSButton!
    @IBOutlet weak var rcSoa: NSButton!
    @IBOutlet weak var rcSrv: NSButton!
    @IBOutlet weak var rcTxt: NSButton!
    @IBOutlet weak var rcAny: NSButton!
    @IBOutlet weak var dnsPort: NSTextField!
    @IBOutlet weak var dnsSource: NSTextField!
    @IBOutlet weak var dnsTimeout: NSTextField!
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        let selectedResourceType = defaults.string(forKey: "resourceType")
        let iPv4Value = defaults.string(forKey: "iPv4")
        let iPv6Value = defaults.string(forKey: "iPv6")
        let dnsPortValue = defaults.string(forKey: "dnsPort")
        let dnsSourceValue = defaults.string(forKey: "dnsSource")
        let dnsTimeoutValue = defaults.string(forKey: "dnsTimeout")
        
        switch selectedResourceType {
            case "A":
                rcA.state = NSControl.StateValue.on
            case "AAAA":
                rcAAAA.state = NSControl.StateValue.on
            case "ALIAS":
                rcAlias.state = NSControl.StateValue.on
            case "CNAME":
                rcCname.state = NSControl.StateValue.on
            case "MX":
                rcMx.state = NSControl.StateValue.on
            case "NS":
                rcNs.state = NSControl.StateValue.on
            case "PTR":
                rcPtr.state = NSControl.StateValue.on
            case "SOA":
                rcSoa.state = NSControl.StateValue.on
            case "SRV":
                rcSrv.state = NSControl.StateValue.on
            case "TXT":
                rcTxt.state = NSControl.StateValue.on
            default:
                rcAny.state = NSControl.StateValue.on
        }
        
        if selectedResourceType == nil {
            // first value
            defaults.set("rcAny", forKey: "resourceType")
        }
        
        if dnsPortValue != nil {
            dnsPort.stringValue = dnsPortValue!
        }
        else {
            // first value
            defaults.set("53", forKey: "dnsPortValue")
            dnsPort.stringValue = "53"
        }
        
        if dnsSourceValue != nil {
            dnsSource.stringValue = dnsSourceValue!
        }
        else {
            // first value
            defaults.set("8.8.8.8", forKey: "dnsSourceValue")
            dnsSource.stringValue = "8.8.8.8"
        }
        
        if dnsTimeoutValue != nil {
            dnsTimeout.stringValue = dnsTimeoutValue!
        }
        else {
            // first value
            defaults.set("5", forKey: "dnsTimeoutValue")
            dnsTimeout.stringValue = "5"
        }
        
        if iPv4Value != nil {
            if iPv4Value == "on" {
                iPv4.state = NSControl.StateValue.on
            }
        }
        else {
            // first value
            iPv4.state = NSControl.StateValue.on
            defaults.set("on", forKey: "iPv4")
        }
        
        if iPv6Value != nil {
            if iPv6Value == "on" {
                iPv6.state = NSControl.StateValue.on
            }
        }
        else {
            // first value
            iPv6.state = NSControl.StateValue.on
            defaults.set("on", forKey: "iPv6")
        }
        
        defaults.synchronize()
    }
    
    func windowWillClose(_ notification: Notification) {
        
    }
    
    @IBAction func iPv4Click(_ sender: NSButton) {
        let key = "iPv4"
        let defaults = UserDefaults.standard
        let state = iPv4.state == NSControl.StateValue.on ? "on" : "off"
        defaults.set(state, forKey: key)
        defaults.synchronize()
    }
    
    @IBAction func iPv6Click(_ sender: NSButton) {
        let key = "iPv6"
        let defaults = UserDefaults.standard
        let state = iPv6.state == NSControl.StateValue.on ? "on" : "off"
        defaults.set(state, forKey: key)
        defaults.synchronize()
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
        
        let key = "resourceType"
        let defaults = UserDefaults.standard
        var RcType: String
        
        switch sender as! NSButton {
            case rcA:
                RcType = "A"
            case rcAAAA:
                RcType = "AAAA"
            case rcAlias:
                RcType = "ALIAS"
            case rcCname:
                RcType = "CNAME"
            case rcMx:
                RcType = "MX"
            case rcNs:
                RcType = "NS"
            case rcPtr:
                RcType = "PTR"
            case rcSoa:
                RcType = "SOA"
            case rcSrv:
                RcType = "SVR"
            case rcTxt:
                RcType = "TXT"
            default:
                RcType = "ANY"
        }
        
        defaults.set(RcType, forKey: key)
        defaults.synchronize()
    }
    
    @IBAction func dnsPortChange(_ sender: NSTextField) {
        let key = "dnsPort"
        let defaults = UserDefaults.standard
        let value = dnsPort.stringValue
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    @IBAction func dnsSourceChange(_ sender: NSTextField) {
        let key = "dnsSource"
        let defaults = UserDefaults.standard
        let value = dnsSource.stringValue
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    @IBAction func dnsTimeoutChange(_ sender: NSTextField) {
        let key = "dnsTimeout"
        let defaults = UserDefaults.standard
        let value = dnsTimeout.stringValue
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
