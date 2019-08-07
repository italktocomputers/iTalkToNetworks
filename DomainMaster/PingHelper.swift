//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class PingHelper {
    /*
    static func ping(domain: String) -> PingRow {
        let timeout = Helper.getSetting(name: "pingTimeout")
        let results = Helper.shell("ping -c 1 -t \(timeout) \(domain)")
        return parseResponse(results: results)
    }
    */

    static func ping(domain: String, controller: PingViewController) {
        let c: Int32 = 2
        let array: [String?] = ["", domain, nil]
        var cargs = array.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
        let response = UnsafeMutablePointer<Int8>.allocate(capacity: 10000)
        start_ping(c, &cargs, response, controller.newPing)

        for ptr in cargs {
            free(UnsafeMutablePointer(mutating: ptr))
        }
    }
    
    /*
     PING www.google.com (172.217.11.36): 56 data bytes
     64 bytes from 172.217.11.36: icmp_seq=0 ttl=53 time=267.126 ms
     
     --- www.google.com ping statistics ---
     1 packets transmitted, 1 packets received, 0.0% packet loss
     round-trip min/avg/max/stddev = 267.126/267.126/267.126/0.000 ms
    */
    static func parseResponse(results: String) -> [PingRow] {
        var tblData: [PingRow] = []
        let rows = results.split(separator: "\n")
        let regex = try? NSRegularExpression(
            pattern: "^([0-9]{1,}) bytes from ([0-9.]{1,}): icmp_seq=([0-9]{1,}) ttl=([0-9]{1,}) time=([0-9.]{1,}) ms$",
            options: NSRegularExpression.Options.caseInsensitive
        )

        var bytes = 0
        var from = "N/A"
        var seq = 0
        var ttl = 0
        var time = 0.0

        if results.contains("cannot resolve") {
            return [PingRow(bytes: 0, from: results, seq: -1, ttl: 0, time: 0.0)]
        }

        if results.contains("Request timeout") {
            return [PingRow(bytes: 0, from: results, seq: -1, ttl: 0, time: 0.0)]
        }

        var i=0
        for row in rows {
            let myrow = String(row) // deep copy
            let matches = regex!.matches(
                in: String(myrow),
                options: [],
                range: NSRange(location: 0, length: myrow.count)
            )

            if let match = matches.first {
                if let range = Range(match.range(at:1), in: String(myrow)) {
                    bytes = Int(myrow[range]) ?? 0
                }

                if let range = Range(match.range(at:2), in: String(myrow)) {
                    from = String(myrow[range])
                }

                if let range = Range(match.range(at:3), in: String(myrow)) {
                    seq = Int(myrow[range]) ?? 0
                }

                if let range = Range(match.range(at:4), in: String(myrow)) {
                    ttl = Int(myrow[range]) ?? 0
                }

                if let range = Range(match.range(at:5), in: String(myrow)) {
                    time = Double(myrow[range]) ?? 0.0
                }
            }

            tblData.append(
                PingRow(
                    bytes: bytes,
                    from: from,
                    seq: seq,
                    ttl: ttl,
                    time: time
                )
            )

            i=i+1
        }

        return tblData
    }
}
