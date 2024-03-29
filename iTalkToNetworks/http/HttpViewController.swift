//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit
import SwiftUI

class HttpViewController : ViewController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var method: NSComboBox!
    @IBOutlet weak var Url: NSTextField!
    @IBOutlet weak var payload: NSScrollView!
    @IBOutlet weak var rawResponse: NSScrollView!
    @IBOutlet weak var headerTableView: NSTableView!
    @IBOutlet weak var prettyView: NSScrollView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var requestHeadersTableView: NSTableView!
    @IBOutlet weak var port: NSTextField!
    
    @objc dynamic var requestHeaders: [Header] = [Header(name: "Content-Type", value: "application/x-www-form-urlencoded")]
    var headers: [HeaderRow] = []
    
    override func viewDidLoad() {
        headerTableView.delegate = self
        headerTableView.dataSource = self
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
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
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = HttpHelper.toMap(headers: requestHeaders)
        
        if let data = payload.documentView as? NSTextView {
            request.httpBody = data.string.data(using: .utf8)
        }
        
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            
            if (responseString != nil) {
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        // Load raw view
                        if let rawData = rawResponse.documentView as? NSTextView {
                            rawData.string = responseString!
                            
                        }
                        
                        // Load rendered view
                        self.webView.loadHTMLString(responseString!, baseURL: url)
                        
                        // Load header view
                        self.headers = HttpHelper.parseResponse(results: response.allHeaderFields)
                        self.headerTableView.reloadData()
                        
                        // Load pretty view
                        if let prettyData = prettyView.documentView as? NSTextView {
                            prettyData.string = responseString!
                        }
                    }
                }
            }
        }

        task.resume()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return headers.count
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
    
    @IBAction func addHeader(_ sender: Any) {
        requestHeaders.append(Header(name: "Name", value: "Value"))
    }
    
    
    @IBAction func deleteHeader(_ sender: Any) {
        requestHeaders.remove(at: requestHeadersTableView.selectedRow)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.destinationController is PresetSaveViewController {
            let vc = segue.destinationController as? PresetSaveViewController
            vc?.method = self.method.stringValue
            vc?.url = self.Url.stringValue
            vc?.port = Int(self.port.stringValue)! // Fix later`
            
            if let payloadData = payload.documentView as? NSTextView {
                vc?.payload = payloadData.string
            }
            
            vc?.headers = self.requestHeaders
        }
    }
    
}
