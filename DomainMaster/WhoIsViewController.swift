//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class WhoIsViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate {
    @IBOutlet weak var registrarName: NSTextField!
    @IBOutlet weak var registrarUrl: NSTextField!
    @IBOutlet weak var registrarServer: NSTextField!
    @IBOutlet weak var registrarIanaId: NSTextField!
    @IBOutlet weak var registrarAbuseEmail: NSTextField!
    @IBOutlet weak var registrarAbusePhone: NSTextField!
    
    @IBOutlet weak var registrantName: NSTextField!
    @IBOutlet weak var registrantState: NSTextField!
    @IBOutlet weak var registrantCountry: NSTextField!
    @IBOutlet weak var registrantEmail: NSTextField!
    @IBOutlet weak var registrantAdminEmail: NSTextField!
    @IBOutlet weak var registrantTechEmail: NSTextField!
    
    @IBOutlet weak var domain: NSTextField!
    @IBOutlet weak var createdOn: NSTextField!
    @IBOutlet weak var updatedOn: NSTextField!
    @IBOutlet weak var expires: NSTextField!
}
