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
    @IBOutlet weak var packetsReceivedPercentage: NSTextField!
    @IBOutlet weak var startTime: NSTextField!
    @IBOutlet weak var timeElapsed: NSTextField!
    @IBOutlet weak var endTime: NSTextField!

    var data: [PingRow] = []
    var pingStartTime = Date()
    var pingEndTime = Date()
    var pingElapsedTime: TimeInterval = Date().timeIntervalSinceNow
    var pingPacketsTransmitted = 0
    var pingPacketsReceived = 0
    var okToPing = UnsafeMutablePointer<Bool>.allocate(capacity: 1)

    func ping_notify(res: UnsafeMutablePointer<Int8>?, err: UnsafeMutablePointer<Int8>?, transmitted: UnsafeMutablePointer<Int>?, received: UnsafeMutablePointer<Int>?) {
        pingPacketsReceived = received!.pointee
        pingPacketsTransmitted = transmitted!.pointee

        data = PingHelper.parseResponse(results: String(cString: res!))

        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateStats()
        }
    }
    
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
            okToPing.pointee = false
        }
    }

    func updateStats() {
        if pingPacketsTransmitted == pingPacketsReceived {
            packetsReceivedPercentage.stringValue = "100"
        }
        else {
            if pingPacketsTransmitted != 0 && pingPacketsReceived != 0 {
                let percentage = Int(round(Double(pingPacketsReceived)/Double(pingPacketsTransmitted)*100.0))
                packetsReceivedPercentage.stringValue = String(percentage)
            }
            else {
                packetsReceivedPercentage.stringValue = "0"
            }
        }

        packetsTransmitted.stringValue = String(pingPacketsTransmitted)
        packetsReceived.stringValue = String(pingPacketsReceived)

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
        packetsReceivedPercentage.stringValue = "0%"
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
        okToPing.pointee = true
        btn.title = "Stop"
        progressBar.isHidden = false
        inputBox.isEnabled = false
        progressBar.startAnimation(self.view)
        UrlCache.add(url: inputBox.stringValue)
        let searchTerm = self.inputBox.stringValue
        let res = UnsafeMutablePointer<CChar>.allocate(capacity: 10000)
        let err = UnsafeMutablePointer<CChar>.allocate(capacity: 10000)
        let transmitted = UnsafeMutablePointer<Int>.allocate(capacity: 10000)
        let received = UnsafeMutablePointer<Int>.allocate(capacity: 10000)

        clearTable()
        clearStats()

        DispatchQueue.global(qos: .userInitiated).async {
            init_res(0, res, err)
            set_ping_notify(self.ping_notify)
            self.setStartTime()
            
            let result = PingHelper.ping(domain: searchTerm, controller: self, okToPing: self.okToPing, transmitted: transmitted, received: received)

            self.setEndTime()

            DispatchQueue.main.async {
                self.inputBox.isEnabled = true
                self.btn.isEnabled = true
                self.progressBar.isHidden = true
                self.btn.title = "Ping"
                self.okToPing.pointee = true

                if result != 0 {
                    // There was an error so we report it to user now.
                    Helper.showErrorBox(view: self, msg: String(cString: err))
                }

                free(UnsafeMutablePointer(mutating: res))
                free(UnsafeMutablePointer(mutating: err))
                free(UnsafeMutablePointer(mutating: transmitted))
                free(UnsafeMutablePointer(mutating: received))
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
                //cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "from"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].from)
                //cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "seq"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].seq)
                //cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ttl"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].ttl)
                //cell.textField?.textColor = txtColor
                return cell
            }
        }
        else if (tableView.tableColumns[4] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "time"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].time)
                //cell.textField?.textColor = txtColor
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
