//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class PingViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate {
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var btn: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var inputBox: NSComboBox!
    
    var data: [PingRow] = []
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        inputBox.delegate = self
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
            inputBox.addItem(withObjectValue: i)
        }
    }
    
    @IBAction func ping(_ sender: Any) {
        startPing()
    }
    
    func startPing() {
        btn.isEnabled = false
        progressBar.isHidden = false
        progressBar.startAnimation(self.view)
        UrlCache.add(url: inputBox.stringValue)
        let searchTerm = self.inputBox.stringValue

        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0...50 {
                let row = PingHelper.ping(domain: searchTerm)
                row.seq = String(i)
                self.data.append(row)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.scrollRowToVisible(i)
                }
                sleep(1)
            }
            DispatchQueue.main.async {
                self.btn.isEnabled = true
                self.progressBar.isHidden = true
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "bytes"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row].bytes
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "from"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].from)
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "seq"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row].seq
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ttl"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row].ttl
                return cell
            }
        }
        else if (tableView.tableColumns[4] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "time"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = self.data[row].time
                return cell
            }
        }
        return nil
    }
    
    @IBAction func comboOnChange(_ sender: Any) {
        if inputBox.stringValue != "" {
            startPing()
        }
    }
}
