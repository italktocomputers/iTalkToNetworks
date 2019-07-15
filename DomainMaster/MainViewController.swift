//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class MainViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate {
    @IBOutlet weak var DNS_Owner: NSTextField!
    @IBOutlet weak var DNS_Email: NSTextField!
    @IBOutlet weak var DNS_Registered: NSTextField!
    @IBOutlet weak var DNS_Expires: NSTextField!
    @IBOutlet weak var DNS_Registrar: NSTextField!
    @IBOutlet weak var DNS_Abuse_Email: NSTextField!
    @IBOutlet weak var DNS_Abuse_Phone: NSTextField!
    @IBOutlet weak var DNS_Timeout: NSTextField!
    @IBOutlet weak var DNS_ProgressBar: NSProgressIndicator!
    @IBOutlet weak var lookupBtn: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var DNS_Domain: NSComboBox!
    
    var data: [DnsRow] = []
    //let dnsSource = GoogleDnsDataSource()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        DNS_Domain.delegate = self
        addUrlCacheToComboBox()
    }
    
    func addUrlCacheToComboBox() {
        let urls = UrlCache.get()
        for i in urls {
            DNS_Domain.addItem(withObjectValue: i)
        }
    }
    
    @IBAction func lookUp(_ sender: Any) {
        start_lookup()
    }
    
    func start_lookup() {
        print(Helper.shell("dig @8.8.8.8 +noall +answer cnn.com ANY"))
        lookupBtn.isEnabled = false
        DNS_ProgressBar.isHidden = false
        DNS_ProgressBar.startAnimation(self.view)
        //data = dnsSource.dnsLookUp(searchTerm: DNS_Domain.stringValue, searchOptions: [])
        UrlCache.add(url: DNS_Domain.stringValue)
        tableView.reloadData()
        lookupBtn.isEnabled = true
        DNS_ProgressBar.isHidden = true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "domain"),
                owner: nil
            ) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row].domain
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ttl"),
                owner: nil
            ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].ttl)
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "type"),
                owner: nil
            ) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row].type
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ip"),
                owner: nil
            ) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row].ip
                return cell
            }
        }
        return nil
    }
    
    @IBAction func comboOnChange(_ sender: Any) {
        if DNS_Domain.stringValue != "" {
            start_lookup()
        }
    }
}
