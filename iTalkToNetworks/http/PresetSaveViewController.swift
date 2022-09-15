//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class PresetSaveViewController : ViewController, NSWindowDelegate {
    var method: String = ""
    var url: String = ""
    var port: Int = 80
    var payload: String = ""
    var headers: [Header] = []
    @IBOutlet weak var name: NSTextField!
    
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func save(_ sender: NSButton) {
        Helper.savePreset(
            name: name.stringValue,
            value: Preset(
                name: name.stringValue,
                url: URL(string: url)!,
                port: port,
                method: method,
                payload: payload,
                headers: headers
            )
        )
        self.view.window?.close()
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}
