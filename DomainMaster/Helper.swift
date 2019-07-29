//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

class Helper {
    static func dialogOK(title: String, text: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    static func dialogOKCancel(title: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    static func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }
    
    static func initTextBox(val: String?, box: NSTextField) {
        if val != nil {
            box.stringValue = val!
        }
    }
    
    static func initCheckBox(val: String?, box: NSButton) {
        if val != nil {
            if val == "on" {
                box.state = NSControl.StateValue.on
            }
            else {
                box.state = NSControl.StateValue.off
            }
        }
    }
    
    static func getSetting(name: String) -> String {
        let defaults = UserDefaults.standard
        let value = defaults.string(forKey: name)
        if (value != nil) {
            return value!
        }
        else {
            return ""
        }
    }
    
    static func saveSetting(key: String, value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    static func loadDefaultSettings() {
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "DefaultSettings", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
            for (i,v) in nsDictionary! {
                Helper.saveSetting(key: i as! String, value: v as! String)
            }
        }
    }
}
