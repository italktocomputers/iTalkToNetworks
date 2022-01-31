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
    @IBOutlet weak var packetsLossed: NSTextField!
    @IBOutlet weak var startTime: NSTextField!
    @IBOutlet weak var timeElapsed: NSTextField!
    @IBOutlet weak var endTime: NSTextField!
    @IBOutlet weak var min: NSTextField!
    @IBOutlet weak var max: NSTextField!
    @IBOutlet weak var average: NSTextField!
    @IBOutlet weak var stddev: NSTextField!
    
    var data: [PingRow] = []
    var pingStartTime = Date()
    var pingEndTime = Date()
    var pingElapsedTime: TimeInterval = Date().timeIntervalSinceNow
    var pingPacketsTransmitted = 0
    var pingPacketsReceived = 0
    var task: Process?
    var stdIn = Pipe()
    var stdOut = Pipe()
    var stdErr = Pipe()
    
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
            beforePing()
            startPing()
        }
        else {
            self.task!.interrupt()
        }
    }
    
    func updateStats(stats: PingStatistics) {
        packetsTransmitted.stringValue = String(stats.transmitted)
        packetsReceived.stringValue = String(stats.received)
        packetsLossed.stringValue = String(stats.lossed)
        min.stringValue = String(stats.min)
        max.stringValue = String(stats.max)
        average.stringValue = String(stats.average)
        stddev.stringValue = String(stats.stddev)
        
        setTimeElapsed()
    }
    
    func clearTable() {
        data = []
        tableView.reloadData()
    }
    
    func clearStats() {
        pingPacketsTransmitted = 0
        pingPacketsReceived = 0
        packetsTransmitted.stringValue = "0"
        packetsReceived.stringValue = "0"
        packetsLossed.stringValue = "0%"
        startTime.stringValue = "yyyy-MM-dd HH:mm:ss"
        endTime.stringValue = "yyyy-MM-dd HH:mm:ss"
        timeElapsed.stringValue = "0"
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
        let domain = self.inputBox.stringValue
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.task = PingHelper.ping(domain: domain, stdIn: &self.stdIn, stdOut: &self.stdOut, stdErr: &self.stdErr)
            
            self.stdOut.fileHandleForReading.readabilityHandler = { fileHandle in
                let buffer = fileHandle.availableData
                if buffer.count > 0 {
                    if let x = PingHelper.parseResponse(results: String(data: buffer, encoding: .utf8)!) {
                        self.data.insert(x, at: 0)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    let stats = PingHelper.parseFinalResponse(results: String(data: buffer, encoding: .utf8)!)
                    DispatchQueue.main.async {
                        self.updateStats(stats: stats)
                    }
                }
            }
            self.task?.terminationHandler = { task in
                DispatchQueue.main.async {
                    self.afterPing()
                }
            }
        }
    }
    
    func beforePing() {
        btn.title = "Stop"
        progressBar.isHidden = false
        inputBox.isEnabled = false
        progressBar.startAnimation(self.view)
        UrlCache.add(url: inputBox.stringValue)
        
        clearTable()
        clearStats()
        
        setStartTime()
    }
    
    func afterPing() {
        btn.title = "Ping"
        btn.isEnabled = true
        progressBar.isHidden = true
        setEndTime()
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
                cell.textField?.stringValue = String(self.data[row].bytes)
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
                cell.textField?.stringValue = String(self.data[row].seq)
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ttl"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].ttl)
                return cell
            }
        }
        else if (tableView.tableColumns[4] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "time"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].time)
                return cell
            }
        }
        return nil
    }
    
    @IBAction func comboOnChange(_ sender: Any) {
        if inputBox.stringValue != "" {
            beforePing()
            startPing()
        }
    }
}

