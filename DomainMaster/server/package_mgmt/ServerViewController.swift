//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit
import WebKit
import SwiftUI

class ServerViewController : ViewController, FileExplorerProtocol {
    @IBOutlet weak var controlTableView: NSTableView!
    @IBOutlet weak var filesTableView: NSTableView!
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.destinationController is FileExplorerViewController {
            let vc = segue.destinationController as? FileExplorerViewController
            vc?.callingViewController = self
        }
    }
    
    func fileSelected(path: String, file: File) {
        print("This is the file selected: \(path)/\(file.fileName)")
    }
    
    @IBAction func saveControlFiles(_ sender: Any) {
        
    }
    
    
    @IBAction func saveFiles(_ sender: Any) {
        
    }
    
}
