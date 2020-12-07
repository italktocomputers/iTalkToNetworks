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
    var payload: String = ""
    var headers: [Header] = []
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func save(_ sender: NSButton) {
        
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}
