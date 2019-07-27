//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class WhoIsSettingsViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var arin: NSButton!
    @IBOutlet weak var apnic: NSButton!
    @IBOutlet weak var nac: NSButton!
    @IBOutlet weak var afriNic: NSButton!
    @IBOutlet weak var interNic: NSButton!
    @IBOutlet weak var iana: NSButton!
    @IBOutlet weak var krnic: NSButton!
    @IBOutlet weak var usNonMilFedGov: NSButton!
    @IBOutlet weak var lacNic: NSButton!
    @IBOutlet weak var radb: NSButton!
    @IBOutlet weak var ripe: NSButton!
    @IBOutlet weak var peeringDb: NSButton!
    @IBOutlet weak var customNic: NSButton!
    @IBOutlet weak var host: NSTextField!
    @IBOutlet weak var port: NSTextField!
    @IBOutlet weak var allowReferrals: NSButton!
    
    override func viewDidLoad() {
        let NIC = Helper.getSetting(name: "whoIsNIC")
        let hostValue = Helper.getSetting(name: "whoIsHost")
        let portValue = Helper.getSetting(name: "whoIsPort")
        let allowReferralsValue = Helper.getSetting(name: "whoIsAllowReferrals")
        
        Helper.initTextBox(val: hostValue, box: host)
        Helper.initTextBox(val: portValue, box: port)
        Helper.initCheckBox(val: allowReferralsValue, box: allowReferrals)
        
        switch NIC {
            case "PeeringDB":
                peeringDb.state = NSButton.StateValue.on
            case "LACNIC":
                lacNic.state = NSButton.StateValue.on
            case "RIPE":
                ripe.state = NSButton.StateValue.on
            case "KRNIC":
                krnic.state = NSButton.StateValue.on
            case "IANA":
                iana.state = NSButton.StateValue.on
            case "ARIN":
                arin.state = NSButton.StateValue.on
            case "AfriNIC":
                afriNic.state = NSButton.StateValue.on
            case "APNIC":
                apnic.state = NSButton.StateValue.on
            case "NAC":
                nac.state = NSButton.StateValue.on
            case "RADB":
                radb.state = NSButton.StateValue.on
            case "usNonMilFedGov":
                usNonMilFedGov.state = NSButton.StateValue.on
            case "InterNIC":
                interNic.state = NSButton.StateValue.on
            case "CustomNIC":
                customNic.state = NSButton.StateValue.on
            default:
                print("Unknown NIC \(NIC)")
        }
    }
    
    @IBAction func NicClick(_ sender: NSButton) {
        print(sender.accessibilityIdentifier())
        Helper.saveSetting(key: "whoIsNIC", value: sender.identifier!.rawValue)
    }
    
    @IBAction func portChange(_ sender: NSTextField) {
        Helper.saveSetting(key: "whoIsPort", value: port.stringValue)
    }
    
    @IBAction func hostChange(_ sender: NSTextField) {
        Helper.saveSetting(key: "whoIsHost", value: host.stringValue)
    }
    
    
    @IBAction func allowReferralsClick(_ sender: Any) {
        Helper.saveSetting(key: "whoIsAllowReferrals", value: "on")
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
