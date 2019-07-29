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
    var pingStartTime = Date()
    var pingEndTime = Date()
    var pingElapsedTime: TimeInterval = Date().timeIntervalSinceNow
    var pingPacketsTransmitted = 0
    var pingPacketsReceived = 0
    var pingPacketsLossed = 0
    var pingPacketsLossedPercentage: Double = 0.0
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        inputBox.delegate = self
        addUrlCacheToComboBox()
        
        // Set font for table header
        tableView.tableColumns.forEach { (column) in
            column.headerCell.attributedStringValue = NSAttributedString(
                string: column.title,
                attributes: [
                    NSAttributedString.Key.font: NSFont(name: "Geneva", size: 13.0) ?? "Arial"
                ]
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
        if (btn.title == "Ping") {
            startPing()
        }
        else {
            okToPing = false
        }
    }

    func updateStats(row: PingRow) {
        pingPacketsTransmitted += 1

        if row.seq == -1 {
            pingPacketsLossed += 1
        }
        else {
            pingPacketsReceived += 1
        }

        if pingPacketsTransmitted != 0 && pingPacketsLossed != 0 {
            pingPacketsLossedPercentage = Double(pingPacketsTransmitted / pingPacketsLossed)
        }
        else {
            pingPacketsLossedPercentage = 0.0
        }

        packetsTransmitted.stringValue = String(pingPacketsTransmitted)
        packetsReceived.stringValue = String(pingPacketsReceived)
        packetLoss.stringValue = String(pingPacketsLossedPercentage)
    }

    func clearTable() {
        data = []
        tableView.reloadData()
    }

    func clearStats() {
        pingPacketsTransmitted = 0
        pingPacketsReceived = 0
        pingPacketsLossed = 0
        pingPacketsLossedPercentage = 0.0
        packetsTransmitted.stringValue = "00"
        packetsReceived.stringValue = "00"
        packetLoss.stringValue = "0.0%"
        startTime.stringValue = "__/__/____ __:__:__"
        endTime.stringValue = "__/__/____ __:__:__"
        timeElapsed.stringValue = "0.0"
    }

    func setStartTime() {
        DispatchQueue.main.async {
            self.pingStartTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.startTime.stringValue = formatter.string(from: self.pingStartTime)
        }
    }

    func setEndTime() {
        DispatchQueue.main.async {
            self.pingEndTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.endTime.stringValue = formatter.string(from: self.pingEndTime)
        }
    }

    func setTimeElapsed() {
        DispatchQueue.main.async {
            self.pingElapsedTime = Date().timeIntervalSince(self.pingStartTime).rounded()
            self.timeElapsed.stringValue = String(self.pingElapsedTime)
        }
    }
    
    func startPing() {
        btn.title = "Stop"
        progressBar.isHidden = false
        progressBar.startAnimation(self.view)
        UrlCache.add(url: inputBox.stringValue)
        let searchTerm = self.inputBox.stringValue

        clearTable()
        clearStats()

        DispatchQueue.global(qos: .userInitiated).async {
            self.setStartTime()
            let pingMax = Helper.getSetting(name: "pingMax")

            for i in 1...(Int(pingMax) ?? 1) {
                if self.okToPing == false {
                    break
                }

                let row = PingHelper.ping(domain: searchTerm)
                row.seq = i
                self.data.append(row)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.scrollRowToVisible(i)
                    self.updateStats(row: row)
                    self.setTimeElapsed()
                }

                sleep(1)
            }

            self.setEndTime()

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
        var txtColor = NSColor.white

        if self.data[row].seq == -1 {
            txtColor = NSColor.red
        }
        else if self.data[row].time >= 1000 {
            txtColor = NSColor.red
        }
        else if self.data[row].time >= 600 {
            txtColor = NSColor.orange
        }

        if (tableView.tableColumns[0] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "bytes"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].bytes)
                cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "from"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].from)
                cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "seq"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].seq)
                cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ttl"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].ttl)
                cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[4] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "time"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].time)
                cell.textField?.textColor = txtColor
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
