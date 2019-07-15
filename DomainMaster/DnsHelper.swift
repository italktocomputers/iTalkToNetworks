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
    
    static func do_dsn_search() {
    
    }
}
