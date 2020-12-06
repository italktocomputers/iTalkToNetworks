//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class RequestHeaderViewController : ViewController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var headerTableView: NSTableView!
    
    var headers: [HeaderRow] = []
    
    override func viewDidLoad() {
        headers.append(HeaderRow(name: "CustomHeaderName", value: "CustomHeaderValue"))
        headers.append(HeaderRow(name: "Content-Type", value: "application/x-www-form-urlencoded"))
        headerTableView.delegate = self
        headerTableView.dataSource = self
        
        // Set font for table header
        headerTableView.tableColumns.forEach { (column) in
            column.headerCell.attributedStringValue = NSAttributedString(
                string: column.title,
                attributes: [
                    NSAttributedString.Key.font: NSFont(name: "Geneva", size: 13.0) ?? "Arial"
                ]
            )
        }
        
        headerTableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Header"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.headers[row].name)
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Value"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.headers[row].value)
                return cell
            }
        }
        return nil
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.makeFirstResponder(sender)
    }
    
    
    @IBAction func addHeader(_ sender: Any) {
        headers.append(HeaderRow(name: "Name", value: "Value"))
        headerTableView.reloadData()
    }
    
    
    @IBAction func deleteHeader(_ sender: Any) {
    }
    
}
