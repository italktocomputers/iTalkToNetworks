//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

class FileExplorerViewController : ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var pathLabel: NSTextField!
    
    var data: [File] = []
    let fileManager = FileManager.default
    var path = NSHomeDirectory()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.action = #selector(fileNameClick)
        
        // Set font for table header
        tableView.tableColumns.forEach { (column) in
            column.headerCell.attributedStringValue = NSAttributedString(
                string: column.title,
                attributes: [
                    NSAttributedString.Key.font: NSFont(name: "Geneva", size: 13.0) ?? "Arial"
                ]
            )
        }
        
        loadDir()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func loadDir() {
        let filenames = getListOfFileNames(path: path)
        pathLabel.stringValue = path
        data = File.initFromArray(fileManager: fileManager, arr: filenames, path:  path)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView.tableColumns[0] == tableColumn) {
            var icon: NSImage? = nil
            
            print(self.data[row].fileKind)
            
            if self.data[row].fileKind == "NSFileTypeDirectory" {
                icon = NSImage(named: NSImage.folderName)!
            }
            else {
                icon = NSImage(named: NSImage.iconViewTemplateName)!
            }
            
            if let cell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "fileicon"),
                owner: nil
                ) as? NSTableCellView {
                if icon != nil {
                    cell.imageView!.image = icon!
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
    
    @IBAction func upDir(_ sender: Any) {
        var pathArray = path.split(separator: "/")
        pathArray.removeLast()
        let newPath = pathArray.joined(separator: "/")
        path = newPath
        print(newPath)
        loadDir()
    }
    
    @IBAction func homeDir(_ sender: Any) {
        path = NSHomeDirectory()
        loadDir()
    }
    
    @IBAction func rootDir(_ sender: Any) {
        path = "/"
        loadDir()
    }
    
    @objc func fileNameClick() {
        let file = data[tableView.selectedRow]
        
        if file.fileKind == "NSFileTypeDirectory" {
            path = "\(path)/\(data[tableView.selectedRow].fileName)"
        }
        
        loadDir()
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
