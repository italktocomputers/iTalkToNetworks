//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let defaults = UserDefaults.standard
        let value = defaults.string(forKey: "init")
        if (value == nil) {
            Helper.loadDefaultSettings()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}

