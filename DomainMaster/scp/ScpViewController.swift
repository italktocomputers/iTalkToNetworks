//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit
import SwiftUI

class ScpViewController : ViewController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, FileExplorerProtocol {
    func allowSelectDirectory() -> Bool {
        return true
    }
    
    func allowSelectFile() -> Bool {
        return true
    }
    
    func fileSelected(path: String, file: File) {
        print("Choose \(path)/\(file.fileName)")
    }
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.destinationController is FileExplorerViewController {
            let vc = segue.destinationController as? FileExplorerViewController
            vc?.callingViewController = self
        }
    }
}
