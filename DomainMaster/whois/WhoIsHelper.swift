//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class WhoIsHelper {
    static func whoIsLookUp(domain: String, res: UnsafeMutablePointer<CChar>, err: UnsafeMutablePointer<CChar>) -> Int32 {
        var ret: Int32 = 0
        let c: Int32
        let host = Helper.getSetting(name: "whoIsHost")
        let port = Helper.getSetting(name: "whoIsPort")
        let nic = Helper.getSetting(name: "whoIsNIC")
        let referrals = Helper.getSetting(name: "whoIsAllowReferrals")
        
        var uargs: [String?] = []
        
        uargs.append("")
        
        if nic == "CustomNIC" {
            uargs.append("-p")
            uargs.append(port)
            uargs.append("-h")
            uargs.append(host)
        }
        else {
            let flag = settingToFlag(setting: nic)
            uargs.append("-\(flag)")
        }
        
        if referrals == "off" {
            uargs.append("-Q")
        }
        
        uargs.append(domain)
        uargs.append(nil)
        
        c = Int32(uargs.count - 1)
        
        var cargs = uargs.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
        
        ret = start_whois(c, &cargs, res, err)
        
        for ptr in cargs {
            free(UnsafeMutablePointer(mutating: ptr))
        }
        
        return ret
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
