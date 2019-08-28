//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Cocoa

class ErrorBoxViewController: NSViewController {
    @IBOutlet weak var msg: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(self)
    }
}

