//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

class FileExplorerViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    var data: [File] = []
    let fileManager = FileManager.default
    
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
        
        let filenames = getListOfFileNames(path: NSHomeDirectory())
        data = File.initFromArray(fileManager: fileManager, arr: filenames, path:  NSHomeDirectory())
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            if self.data[row].fileKind == "NSFileTypeDirectory" {
                
            }
            else if self.data[row].fileKind == "NSFileTypeRegular" {
                
            }
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "fileicon"),
                owner: nil
                ) as? NSTableCellView {
                if #available(OSX 10.15, *) {
                    cell.imageView = NSImageView(image: NSImage(named: NSImage.folderName)!)
                } else {
                    // Fallback on earlier versions
                }
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "filename"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].fileName)
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "filesize"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].fileSize)
                return cell
            }
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "fileadded"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].fileAdded)
                return cell
            }
        }
        
        return nil
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    func getListOfFileNames(path: String) -> Array<String> {
        var docsArray: Array<String> = []

        do {
            docsArray = try fileManager.contentsOfDirectory(atPath: path)
        }
        catch {
            print(error)
        }
        
        return docsArray
    }
}
