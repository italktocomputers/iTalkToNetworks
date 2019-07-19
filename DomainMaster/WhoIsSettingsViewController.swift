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
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        let arinValue = defaults.string(forKey: "arin")
        let apnicValue = defaults.string(forKey: "apnic")
        let nacValue = defaults.string(forKey: "nac")
        let afriNicValue = defaults.string(forKey: "afriNic")
        let interNicValue = defaults.string(forKey: "interNic")
        let ianaValue = defaults.string(forKey: "iana")
        let krnicValue = defaults.string(forKey: "krnic")
        let usNonMilFedGovValue = defaults.string(forKey: "usNonMilFedGov")
        let lacNicValue = defaults.string(forKey: "lacNic")
        let radbValue = defaults.string(forKey: "radb")
        let ripeValue = defaults.string(forKey: "ripe")
        let peeringDbValue = defaults.string(forKey: "peeringDb")
        let customNicValue = defaults.string(forKey: "customNic")
        let hostValue = defaults.string(forKey: "host")
        let portValue = defaults.string(forKey: "port")
        
        Helper.initTextBox(val: hostValue, box: host)
        Helper.initTextBox(val: portValue, box: port)
        
        Helper.initCheckBox(val: arinValue, box: arin)
        Helper.initCheckBox(val: apnicValue, box: apnic)
        Helper.initCheckBox(val: nacValue, box: nac)
        Helper.initCheckBox(val: afriNicValue, box: afriNic)
        Helper.initCheckBox(val: interNicValue, box: interNic)
        Helper.initCheckBox(val: ianaValue, box: iana)
        Helper.initCheckBox(val: krnicValue, box: krnic)
        Helper.initCheckBox(val: usNonMilFedGovValue, box: usNonMilFedGov)
        Helper.initCheckBox(val: lacNicValue, box: lacNic)
        Helper.initCheckBox(val: radbValue, box: radb)
        Helper.initCheckBox(val: ripeValue, box: ripe)
        Helper.initCheckBox(val: peeringDbValue, box: peeringDb)
        Helper.initCheckBox(val: customNicValue, box: customNic)
    }
    
    @IBAction func NicClick(_ sender: NSButton) {
        //let a = sender as! NSButton
    }
    
    @IBAction func portChange(_ sender: NSTextField) {
        Helper.saveSetting(key: "whoIsPort", value: port.stringValue)
    }
    
    @IBAction func hostChange(_ sender: NSTextField) {
        Helper.saveSetting(key: "whoIsHost", value: host.stringValue)
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
