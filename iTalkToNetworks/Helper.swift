//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

extension String: Error {}

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
    
    static func kill(pId: Int32) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["kill -9 \(pId)"]
        task.launch()
    }
    
    static func shell(stdIn: inout Pipe, stdOut: inout Pipe, stdErr: inout Pipe, _ command: String) -> Process {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.standardInput = stdIn
        task.standardOutput = stdOut
        task.standardError = stdErr
        task.launch()
        
        return task
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
    
    static func getPresets() -> [(name: String, preset: Preset)] {
        var presets: [(name: String, preset: Preset)] = []
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.hasPrefix("PRESET-") {
                do {
                    let preset = try JSONDecoder().decode(Preset.self, from: value as! Data)
                    presets.append((name: String(key.dropFirst(7)), preset: preset))
                }
                catch {
                    print(error) // Fix this (should show error dialog)
                }
            }
        }
        
        return presets
    }
    
    static func savePreset(name: String, value: Preset) {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(value)
            defaults.set(data, forKey: "PRESET-\(name)")
            defaults.synchronize()
        }
        catch {
            print(error) // Fix this (should show error dialog)
        }
    }
    
    static func deletePreset(name: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "PRESET-\(name)")
        defaults.synchronize()
    }
}
