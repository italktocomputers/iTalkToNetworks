//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class HttpSettingsViewController : ViewController, NSWindowDelegate {
    override func viewDidLoad() {
        
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}
