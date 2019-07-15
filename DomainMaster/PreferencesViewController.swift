//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class PreferencesViewController : ViewController {
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
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        let selectedResourceType = defaults.string(forKey: "ResourceType")
        let iPv4Value = defaults.string(forKey: "iPv4")
        let iPv6Value = defaults.string(forKey: "iPv6")
        let dnsPortValue = defaults.string(forKey: "dnsPort")
        let dnsSourceValue = defaults.string(forKey: "dnsSource")
        
        switch selectedResourceType {
            case "rcA":
                rcA.state = NSControl.StateValue.on
            case "rcAAAA":
                rcAAAA.state = NSControl.StateValue.on
            case "rcAlias":
                rcAlias.state = NSControl.StateValue.on
            case "rcCname":
                rcCname.state = NSControl.StateValue.on
            case "rcMx":
                rcMx.state = NSControl.StateValue.on
            case "rcNs":
                rcNs.state = NSControl.StateValue.on
            case "rcPtr":
                rcPtr.state = NSControl.StateValue.on
            case "rcSoa":
                rcSoa.state = NSControl.StateValue.on
            case "rcSrv":
                rcSrv.state = NSControl.StateValue.on
            case "rcTxt":
                rcTxt.state = NSControl.StateValue.on
            default:
                rcAny.state = NSControl.StateValue.on
        }
        
        if selectedResourceType == nil {
            // first value
            defaults.set("rcAny", forKey: "ResourceType")
        }
        
        if dnsPortValue != nil {
            dnsPort.stringValue = dnsPortValue!
        }
        else {
            // first value
            defaults.set("53", forKey: "dnsPortValue")
        }
        
        if dnsSourceValue != nil {
            dnsSource.stringValue = dnsSourceValue!
        }
        else {
            // first value
            defaults.set("8.8.8.8", forKey: "dnsSourceValue")
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
        
        let key = "ResourceType"
        let defaults = UserDefaults.standard
        var RcType: String
        
        switch sender as! NSButton {
            case rcA:
                RcType = "rcA"
            case rcAAAA:
                RcType = "rcAAAA"
            case rcAlias:
                RcType = "rcAlias"
            case rcCname:
                RcType = "rcCname"
            case rcMx:
                RcType = "rcMx"
            case rcNs:
                RcType = "rcNs"
            case rcPtr:
                RcType = "rcPtr"
            case rcSoa:
                RcType = "rcSoa"
            case rcSrv:
                RcType = "rcSvr"
            case rcTxt:
                RcType = "rcTxt"
            default:
                RcType = "rcAny"
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
}
