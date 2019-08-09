//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class PingHelper {
    static func ping(domain: String, controller: PingViewController, okToPing: UnsafeMutablePointer<Bool>) -> Int32 {
        var ret: Int32 = 0;
        let c: Int32 = 2
        let array: [String?] = ["", domain, nil]
        var cargs = array.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
        let response = UnsafeMutablePointer<Int8>.allocate(capacity: 10000)
        
        ret = start_ping(c, &cargs, response, controller.newPing, okToPing);

        for ptr in cargs {
            free(UnsafeMutablePointer(mutating: ptr))
        }

        return ret
    }

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
        var i=0
        
        for row in rows {
            if i == 0 {
                i=i+1
                continue; // skip header
            }

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
