//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class PingHelper {
    static func ping(domain: String) -> PingRow {
        let results = Helper.shell("ping -c 1 \(domain)")
        //print(results)
        return parseResponse(results: results)
    }
    
    /*
     PING www.google.com (172.217.11.36): 56 data bytes
     64 bytes from 172.217.11.36: icmp_seq=0 ttl=53 time=267.126 ms
     
     --- www.google.com ping statistics ---
     1 packets transmitted, 1 packets received, 0.0% packet loss
     round-trip min/avg/max/stddev = 267.126/267.126/267.126/0.000 ms
    */
    static func parseResponse(results: String) -> PingRow {
        let rows = results.split(separator: "\n")
        let regex = try? NSRegularExpression(
            pattern: "^([0-9]{1,}) bytes from ([0-9.]{1,}): icmp_seq=([0-9]{1,}) ttl=([0-9]{1,}) time=([0-9.]{1,}) ms$",
            options: NSRegularExpression.Options.caseInsensitive
        )
        let row = rows[1]

        var bytes = ""
        var from = ""
        var seq = ""
        var ttl = ""
        var time = ""
        let myrow = String(row) // deep copy

        //print(myrow)

        let matches = regex!.matches(
            in: String(myrow),
            options: [],
            range: NSRange(location: 0, length: myrow.count)
        )

        if let match = matches.first {
            if let range = Range(match.range(at:1), in: String(myrow)) {
                bytes = String(myrow[range])
            }

            if let range = Range(match.range(at:2), in: String(myrow)) {
                from = String(myrow[range])
            }

            if let range = Range(match.range(at:3), in: String(myrow)) {
                seq = String(myrow[range])
            }

            if let range = Range(match.range(at:4), in: String(myrow)) {
                ttl = String(myrow[range])
            }

            if let range = Range(match.range(at:5), in: String(myrow)) {
                time = String(myrow[range])
            }
        }

        return PingRow(
            bytes: bytes,
            from: from,
            seq: seq,
            ttl: ttl,
            time: time
        )
    }
}
