//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class RequestHeaderViewController : ViewController, NSWindowDelegate {
    @IBOutlet weak var headerTableView: NSTableView!
    @objc dynamic var headers: [Header] = [Header(name: "Content-Type", value: "application/x-www-form-urlencoded")]
    
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
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.makeFirstResponder(sender)
    }
    
    @IBAction func addHeader(_ sender: Any) {
        headers.append(Header(name: "Name", value: "Value"))
    }
    
    
    @IBAction func deleteHeader(_ sender: Any) {
        headers.remove(at: headerTableView.selectedRow)
    }
    
}
