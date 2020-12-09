//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class FileExplorerViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    var data: [File] = []
    
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
        
        let filenames = getListOfFileNames()
        data = File.initFromArray(arr: filenames)
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "filename"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].fileName)
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "filesize"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].fileSize)
                return cell
            }
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "filekind"),
                owner: nil
                ) as? NSTableCellView {
                cell.textField?.stringValue = String(self.data[row].fileKind)
                return cell
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
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
    
    func getListOfFileNames() -> Array<String> {
        let docsPath = NSHomeDirectory()
        let fileManager = FileManager.default
        var docsArray: Array<String> = []

        do {
            docsArray = try fileManager.contentsOfDirectory(atPath: docsPath)
        }
        catch {
            print(error)
        }
        
        return docsArray
    }
    
    func getFileattributes(fileManager: FileManager, fileName: String, path: String) -> [FileAttributeKey: Any] {
        var attributes: [FileAttributeKey: Any] = [:]
        
        do {
            attributes = try fileManager.attributesOfItem(atPath: "\(path)/\(fileName)")
        }
        catch {
            print(error)
        }
        
        return attributes
    }
}
