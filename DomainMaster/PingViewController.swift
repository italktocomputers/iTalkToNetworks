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
    
    @IBOutlet weak var packetsTransmitted: NSTextField!
    @IBOutlet weak var packetsReceived: NSTextField!
    @IBOutlet weak var packetLoss: NSTextField!
    @IBOutlet weak var startTime: NSTextField!
    @IBOutlet weak var timeElapsed: NSTextField!
    @IBOutlet weak var endTime: NSTextField!

    var data: [PingRow] = []
    var pingCount = 10
    var okToPing = true
    
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
        let btn = sender as! NSButton
        print(btn.title)
        if (btn.title == "Ping") {
            startPing()
        }
        else {
            okToPing = false
        }
    }

    func updateStats() {

    }

    func clearTable() {
        data = []
        tableView.reloadData()
    }
    
    func startPing() {
        btn.title = "Stop"
        progressBar.isHidden = false
        progressBar.startAnimation(self.view)
        UrlCache.add(url: inputBox.stringValue)
        let searchTerm = self.inputBox.stringValue

        clearTable()

        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0...self.pingCount {
                if self.okToPing == false {
                    break
                }
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
                self.btn.title = "Ping"
                self.okToPing = true
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