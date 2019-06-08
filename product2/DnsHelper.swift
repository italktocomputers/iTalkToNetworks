//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 Andrew Schools. All rights reserved.
//

import Foundation

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
}
