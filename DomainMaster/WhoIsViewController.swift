//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class WhoIsViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate {
    @IBOutlet weak var searchBox: NSComboBox!
    @IBOutlet weak var searchBtn: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
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
    
    var map = [String:NSTextField?]()
    
    override func viewDidLoad() {
        searchBox.delegate = self
        addUrlCacheToComboBox()
    
        map["Registrar"] = registrarName
        map["Registrar URL"] = registrarUrl
        map["Registrar WHOIS Server"] = registrarServer
        map["Registrar IANA ID"] = registrarIanaId
        map["Registrar Abuse Contact Email"] = registrarAbuseEmail
        map["Registrar Abuse Contact Phone"] = registrarAbusePhone
        map["Registrant Organization"] = registrantName
        map["Registrant State/Province"] = registrantState
        map["Registrant Country"] = registrantCountry
        map["Registrant Email"] = registrantEmail
        map["Admin Email"] = registrantAdminEmail
        map["Tech Email"] = registrantTechEmail
        map["Domain Name"] = domain
        map["Creation Date"] = createdOn
        map["Updated Date"] = updatedOn
        map["Registrar Registration Expiration Date"] = expires
    }
    
    func addUrlCacheToComboBox() {
        let urls = UrlCache.get()
        for i in urls {
            searchBox.addItem(withObjectValue: i)
        }
    }
    
    func startSearch() {
        searchBtn.isEnabled = false
        progressBar.isHidden = false
        progressBar.startAnimation(self.view)
        UrlCache.add(url: searchBox.stringValue)
        let searchTerm = searchBox.stringValue
        
        DispatchQueue.global(qos: .userInitiated).async {
            let data: [String: String] = WhoIsHelper.whoIsLookUp(domain: searchTerm)
            
            for (i,v) in data {
                self.map[i]!!.stringValue = v
            }
            
            DispatchQueue.main.async {
                self.searchBtn.isEnabled = true
                self.progressBar.isHidden = true
            }
        }
    }
    
    @IBAction func onSearch(_ sender: NSButton) {
        startSearch()
    }
    
    @IBAction func comboOnChange(_ sender: Any) {
        if searchBox.stringValue != "" {
            startSearch()
        }
    }
}
