//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class PresetManagerViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {
    @IBOutlet weak var tableView: NSTableView!
    var data: [(name: String, preset: Preset)] = []
    var selectedRow: IndexPath?
    
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set font for table header
        tableView.tableColumns.forEach { (column) in
            column.headerCell.attributedStringValue = NSAttributedString(
                string: column.title,
                attributes: [
                    NSAttributedString.Key.font: NSFont(name: "Geneva", size: 13.0) ?? "Arial"
                ]
            )
        }
        
        data = Helper.getPresets()
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Name"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].name)
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Preset"),
                owner: nil
                ) as? NSTableCellView {
                let method = String(self.data[row].preset.method)
                let url = String(self.data[row].preset.url.absoluteString)
                let port = String(self.data[row].preset.port)
                cell.textField?.stringValue = "\(method.uppercased()) \(url):\(port)"
                return cell
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func delete(_ sender: NSButton) {
        //Helper.deletePreset(name: name as! String)
    }
    
    @IBAction func open(_ sender: NSButton) {
        
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}
