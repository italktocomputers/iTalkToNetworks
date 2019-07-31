//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class TraceRouteViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate {
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var btn: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var inputBox: NSComboBox!

    var data: [TraceRouteRow] = []

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

    @IBAction func trace(_ sender: Any) {
        start()
    }

    func clearTable() {
        data = []
        tableView.reloadData()
    }

    func start() {
        btn.isEnabled = false
        progressBar.isHidden = false
        progressBar.startAnimation(self.view)
        UrlCache.add(url: inputBox.stringValue)
        let searchTerm = self.inputBox.stringValue

        DispatchQueue.global(qos: .userInitiated).async {
            self.data = TraceRouteHelper.trace(domain: searchTerm)
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "hop"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].hop)
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "host"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].host)
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rtt1"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].rtt1)
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rtt2"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].rtt2)
                return cell
            }
        }
        else if (tableView.tableColumns[4] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rtt3"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].rtt3)
                return cell
            }
        }
        return nil
    }

    @IBAction func comboOnChange(_ sender: Any) {
        if inputBox.stringValue != "" {
            start()
        }
    }
}
