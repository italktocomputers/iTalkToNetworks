//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class WhoIsHelper {
    static func whoIsLookUp(domain: String) -> [String:String] {
        var whoIsString = ""
        let host = Helper.getSetting(name: "whoIsHost")
        let port = Helper.getSetting(name: "whoIsPort")
        let nic = Helper.getSetting(name: "whoIsNIC")
        let referrals = Helper.getSetting(name: "whoIsAllowReferrals")
        
        if referrals == "on" {
            whoIsString += "-R "
        }
        else {
            whoIsString += "-Q "
        }
        
        if nic == "CustomNIC" {
            whoIsString += "-h \(host) -p \(port) "
        }
        else {
            let flag = settingToFlag(setting: nic)
            whoIsString += "-\(flag) "
        }
        
        print("whois \(whoIsString)\(domain)")
        
        let results = Helper.shell("whois \(whoIsString)\(domain)")
        print(results)
        return parseWhoIsResponse(results: results)
    }
    
    static func settingToFlag(setting: String) -> String {
        switch setting {
            case "ARIN":
                return "a"
            case "APNIC":
                return "A"
            case "NAC":
                return "b"
            case "AfriNIC":
                return "f"
            case "usNonMilFedGov":
                return "g"
            case "InterNIC":
                return "i"
            case "IANA":
                return "I"
            case "KRNIC":
                return "K"
            case "LACNIC":
                return "l"
            case "RADB":
                return "m"
            case "PeeringDB":
                return "P"
            case "RIPE":
                return "r"
            default:
                return "I"
        }
    }
    
    static func findField(string: String, label: String) -> String? {
        let pattern = try! NSRegularExpression(
            pattern: "\(label):\\s(.+)",
            options: NSRegularExpression.Options.caseInsensitive
        )
        
        let matches = pattern.matches(
            in: String(string),
            options: [],
            range: NSRange(location: 0, length: string.count)
        )
        
        if let match = matches.first {
            if let range = Range(match.range(at:1), in: String(string)) {
                return String(string[range])
            }
        }
        
        return nil
    }
    
    static func parseWhoIsResponse(results: String) -> [String: String] {
        var data: [String: String] = [:]
        
        let fields = [
            "Registrar",
            "Registrar URL",
            "Registrar WHOIS Server",
            "Registrar IANA ID",
            "Registrar Abuse Contact Email",
            "Registrar Abuse Contact Phone",
            "Registrant Organization",
            "Registrant State/Province",
            "Registrant Country",
            "Registrant Email",
            "Admin Email",
            "Tech Email",
            "Domain Name",
            "Creation Date",
            "Updated Date",
            "Registrar Registration Expiration Date"
        ]
        
        for field in fields {
            if let fieldValue = findField(string: results, label: field) {
                data[field] = fieldValue
            }
        }
        
        return data
    }
}
