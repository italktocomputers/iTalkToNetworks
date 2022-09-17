//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class DnsViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate {
    @IBOutlet weak var dnsProgressBar: NSProgressIndicator!
    @IBOutlet weak var lookupBtn: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var dnsDomain: NSComboBox!
    
    var data: [DnsRow] = []
    var task: Process?
    var stdIn = Pipe()
    var stdOut = Pipe()
    var stdErr = Pipe()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        dnsDomain.delegate = self
        addUrlCacheToComboBox()
        
        // Set font for table header
        tableView.tableColumns.forEach { (column) in
            column.headerCell.attributedStringValue = NSAttributedString(
                string: column.title,
                attributes: [NSAttributedString.Key.font: NSFont(name: "Geneva", size: 13.0) ?? "Arial"]
            )
        }
    }
    
    func addUrlCacheToComboBox() {
        let urls = UrlCache.get()
        for i in urls {
            dnsDomain.addItem(withObjectValue: i)
        }
    }
    
    @IBAction func lookUp(_ sender: Any) {
        startLookup()
    }
    
    func startLookup() {
        let value = self.dnsDomain.stringValue
        DispatchQueue.global(qos: .userInitiated).async {
            self.task = DnsHelper.dnsLookUp(domain: value, stdIn: &self.stdIn, stdOut: &self.stdOut, stdErr: &self.stdErr)
            
            self.stdOut.fileHandleForReading.readabilityHandler = { fileHandle in
                do {
                    if let buffer = try fileHandle.readToEnd() {
                        if (buffer.count > 0) {
                            let data = DnsHelper.parseResponse(results: String(data: buffer, encoding: .utf8)!)
                            self.data.insert(contentsOf: data, at: 0)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.afterLookup()
                            }
                        }
                    }
                }
                catch {
                    Helper.showErrorBox(view: self, msg: "Cannot read stdOut buffer")
                }
            }
            
            self.stdErr.fileHandleForReading.readabilityHandler = { fileHandle in
                do {
                    if let buffer = try fileHandle.readToEnd() {
                        print("2 \(buffer)")
                        if (buffer.count > 0) {
                            DispatchQueue.main.async {
                                Helper.showErrorBox(view: self, msg: String(data: buffer, encoding: .utf8)!)
                                self.afterLookup()
                            }
                        }
                    }
                }
                catch {
                    Helper.showErrorBox(view: self, msg: "Cannot read stdErr buffer")
                }
            }
        }
    }
    
    func beforeLookup() {
        lookupBtn.isEnabled = false
        dnsProgressBar.isHidden = false
        dnsProgressBar.startAnimation(self.view)
        UrlCache.add(url: dnsDomain.stringValue)
    }
    
    func afterLookup() {
        self.task = nil
        self.stdIn = Pipe()
        self.stdOut = Pipe()
        self.stdErr = Pipe()
        self.lookupBtn.isEnabled = true
        self.dnsProgressBar.isHidden = true
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
        if dnsDomain.stringValue != "" {
            startLookup()
        }
    }
}
