//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class HttpViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var method: NSComboBox!
    @IBOutlet weak var Url: NSTextField!
    @IBOutlet weak var payload: NSScrollView!
    @IBOutlet weak var rawResponse: NSScrollView!
    @IBOutlet weak var headerTableView: NSTableView!
    
    var headers: [HeaderRow] = []
    
    override func viewDidLoad() {
        // Set font for table header
        headerTableView.tableColumns.forEach { (column) in
            column.headerCell.attributedStringValue = NSAttributedString(
                string: column.title,
                attributes: [
                    NSAttributedString.Key.font: NSFont(name: "Geneva", size: 13.0) ?? "Arial"
                ]
            )
        }
    }
    
    @IBAction func startHttpRequest(_ sender: Any) {
        print("here")
        let url = URL(string: Url.stringValue)!
        var request = URLRequest(url: url)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        if let data = payload.documentView as? NSTextView {
            request.httpBody = data.string.data(using: .utf8)
        }
        
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            
            if (responseString != nil) {
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        if let rawData = rawResponse.documentView as? NSTextView {
                            rawData.string = responseString!
                        }
                    }
                }
            }
        }

        task.resume()
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
    
}
