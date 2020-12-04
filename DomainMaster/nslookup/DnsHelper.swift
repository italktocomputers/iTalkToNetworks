//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class DnsHelper {
    static func getResourceType(by Id:Int) -> String {
        var map: [Int:String] = [
            1:"A",
            28:"AAAA",
            38:"A6",
            18:"AFSDB",
            5:"CNAME",
            39:"DNAME",
            48:"DNSKEY",
            43:"DS",
            108:"EUI48",
            109:"EUI64",
            13:"HINFO",
            20:"ISDN",
            25:"KEY",
            29:"LOC",
            15:"MX",
            35:"NAPTR",
            2:"NS",
            47:"NSEC",
            30:"NXT",
            12:"PTR",
            17:"RP",
            46:"RRSIG",
            21:"RT",
            24:"SIG",
            6:"SOA",
            99:"SPF",
            33:"SRV",
            16:"TXT",
            256:"URI",
            11:"WKS",
            19:"X25"
        ]
        
        return map[Id, default: "N/A"]
    }
    
    static func validateIpAddress(ipToValidate: String) -> Bool {
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            return true
        }
        else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return true
        }
        
        return false;
    }
    
    static func dnsLookUp(domain: String, stdOut: inout Pipe, stdErr: inout Pipe) -> Process {
        var rLookUp = ""
        let defaults = UserDefaults.standard
        let dnsPort = defaults.string(forKey: "dnsPort")
        let dnsSource = defaults.string(forKey: "dnsSource")
        var resourceType = defaults.string(forKey: "resourceType")
        
        if validateIpAddress(ipToValidate: domain) {
            rLookUp = "-x"
            resourceType = "PTR"
        }
        
        return Helper.shell(stdOut: &stdOut, stdErr: &stdErr, "dig -p \(dnsPort!) @\(dnsSource!) +noall +answer \(rLookUp) \(domain) \(resourceType!)")
    }
    
    static func parseResponse(results: String) -> [DnsRow] {
        var tblData: [DnsRow] = []
        let rows = results.split(separator: "\n")
        let regex = try? NSRegularExpression(
            pattern: "^([a-zA-Z0-9\\-.]{1,})[\\t\\s]{1,}([0-9]{1,})[\\t\\s]{1,}([a-zA-Z]{1,})[\\t\\s]{1,}([a-zA-Z]{1,})[\\t\\s]{1,}(.+)$",
            options: NSRegularExpression.Options.caseInsensitive
        )
        
        for row in rows {
            var domain = ""
            var ttl = ""
            var tclass = ""
            var type = ""
            var ip = ""
            let myrow = String(row) // deep copy
            
            let matches = regex!.matches(
                in: String(myrow),
                options: [],
                range: NSRange(location: 0, length: myrow.count)
            )
            
            if let match = matches.first {
                if let domainRange = Range(match.range(at:1), in: String(myrow)) {
                    domain = String(myrow[domainRange])
                }
                
                if let ttlRange = Range(match.range(at:2), in: String(myrow)) {
                    ttl = String(myrow[ttlRange])
                }
                
                if let classRange = Range(match.range(at:3), in: String(myrow)) {
                    tclass = String(myrow[classRange])
                }
                
                if let typeRange = Range(match.range(at:4), in: String(myrow)) {
                    type = String(myrow[typeRange])
                }
                
                if let ipRange = Range(match.range(at:5), in: String(myrow)) {
                    ip = String(myrow[ipRange])
                }
                
                tblData.append(
                    DnsRow(
                        domain: domain,
                        ttl: ttl,
                        type: type,
                        tclass: tclass,
                        ip: ip
                    )
                )
            }
        }
        
        return tblData
    }
}
