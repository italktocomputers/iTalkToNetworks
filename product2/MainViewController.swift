//
//  MainViewController.swift
//  product2
//
//  Created by Andrew Schools on 6/3/19.
//  Copyright © 2019 Andrew Schools. All rights reserved.
//

import Foundation
import AppKit

class MainViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var DNS_Owner: NSTextField!
    @IBOutlet weak var DNS_Email: NSTextField!
    @IBOutlet weak var DNS_Registered: NSTextField!
    @IBOutlet weak var DNS_Expires: NSTextField!
    @IBOutlet weak var DNS_Registrar: NSTextField!
    @IBOutlet weak var DNS_Abuse_Email: NSTextField!
    @IBOutlet weak var DNS_Abuse_Phone: NSTextField!
    @IBOutlet weak var DNS_Timeout: NSTextField!
    @IBOutlet weak var DNS_Domain: NSTextField!
    @IBOutlet weak var DNS_ProgressBar: NSProgressIndicator!
    @IBOutlet weak var lookupBtn: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var data: [[String:Any]] = []
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func lookUp(_ sender: Any) {
        lookupBtn.state = NSControl.StateValue.off
        DNS_ProgressBar.isHidden = false
        DNS_ProgressBar.startAnimation(self.view)
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.lookupBtn.state = NSControl.StateValue.on
            self.DNS_ProgressBar.stopAnimation(nil)
        })
        */
        
        if let url = URL(string: "https://dns.google.com/resolve?name=\(DNS_Domain.stringValue)&type=A") {
            do {
                let contents = try String(contentsOf: url)
                let data = Data(contents.utf8)
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(json["Answer"]!)
                    self.data = (json["Answer"] as? [[String:Any]])!
                    tableView.reloadData()
                }
            }
            catch {
                
            }
        }
        else {
            
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "domain"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row]["name"] as! String
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ttl"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row]["TTL"] as! Int)
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "in"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "IN"
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "type"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row]["type"] as! Int)
                return cell
            }
        }
        else if (tableView.tableColumns[4] == tableColumn) {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ip"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row]["data"] as! String
                return cell
            }
        }
        return nil
    }
}
