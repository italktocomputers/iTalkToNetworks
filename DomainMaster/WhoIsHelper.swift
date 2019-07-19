//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class WhoIsHelper {
    static func whoIsLookUp(domain: String) -> [String:String] {
        //let defaults = UserDefaults.standard
        //let dnsPort = defaults.string(forKey: "dnsPort")
        //let dnsSource = defaults.string(forKey: "dnsSource")
        //var resourceType = defaults.string(forKey: "resourceType")
        
        let results = Helper.shell("whois \(domain)")
        print(results)
        return parseWhoIsResponse(results: results)
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
