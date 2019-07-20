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
        let arinValue = Helper.getSetting(name: "whoIsArin")
        let apnicValue = Helper.getSetting(name: "whoIsApnic")
        let nacValue = Helper.getSetting(name: "whoIsNac")
        let afriNicValue = Helper.getSetting(name: "whoIsAfriNic")
        let interNicValue = Helper.getSetting(name: "whoIsInterNic")
        let ianaValue = Helper.getSetting(name: "whoIsIana")
        let krnicValue = Helper.getSetting(name: "whoIsKrnic")
        let usNonMilFedGovValue = Helper.getSetting(name: "whoIsUsNonMilFedGov")
        let lacNicValue = Helper.getSetting(name: "whoIsLacNic")
        let radbValue = Helper.getSetting(name: "whoIsRadb")
        let ripeValue = Helper.getSetting(name: "whoIsRipe")
        let peeringDbValue = Helper.getSetting(name: "whoIsPeeringDb")
        let customNicValue = Helper.getSetting(name: "whoIsCustomNic")
        let hostValue = Helper.getSetting(name: "whoIsSource")
        let portValue = Helper.getSetting(name: "whoIsPort")
        
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
