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

    static func initDropDown(val: String?, box: NSPopUpButton) {
        if val != nil {
            box.selectItem(withTitle: val!)
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

    static func getDefaultSettings(index: String) -> String? {
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "DefaultSettings", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
            for (i,v) in nsDictionary! {
                if i as! String == index {
                    return v as! String
                }
            }
        }

        return nil
    }

    static func isNumeric(str: String, emptyAllowed: Bool=true) -> Bool {
        if str == "" {
            if emptyAllowed == false {
                return false
            }
            else {
                return true
            }
        }

        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(str).isSubset(of: nums)
    }

    static func between(str: String, from: Int, to: Int, emptyAllowed: Bool=true) -> Bool {
        if str == "" {
            if emptyAllowed == false {
                return false
            }
            else {
                return true
            }
        }

        if let num = Int(str) {
            if num >= from && num <= to {
                return true
            }
        }

        return false
    }

    static func isDecimal(str: String, emptyAllowed: Bool=true) -> Bool {
        if str == "" {
            if emptyAllowed == false {
                return false
            }
            else {
                return true
            }
        }

        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
        if Set(str).isSubset(of: nums) {
            let dotCount = str.filter{$0 == "."}.count
            if dotCount <= 1 {
                if Decimal(string: str) != nil {
                    return true
                }
            }
        }
        return false
    }
    
    static func isIpAddress(str: String, emptyAllowed: Bool=true) -> Bool {
        return true
    }

    static func showIntegerOnlyPopover(view: ViewController, sender: Any) {
        let sb = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let vc: NSViewController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("error_integer_only")) as? NSViewController {

            view.present(vc, asPopoverRelativeTo: ((sender as AnyObject).bounds)!, of: sender as! NSView, preferredEdge: NSRectEdge.maxX, behavior: NSPopover.Behavior.transient)
        }
    }

    static func showDecimalOnlyPopover(view: ViewController, sender: Any) {
        let sb = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let vc: NSViewController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("error_decimal_only")) as? NSViewController {

            view.present(vc, asPopoverRelativeTo: ((sender as AnyObject).bounds)!, of: sender as! NSView, preferredEdge: NSRectEdge.maxX, behavior: NSPopover.Behavior.transient)
        }
    }

    static func showErrorBox(view: ViewController, msg: String) {
        let sb = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let vc: ErrorBoxViewController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("errorbox")) as? ErrorBoxViewController {
            view.presentAsSheet(vc)
            vc.msg.stringValue = msg
        }
    }
}
