//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

/*
struct swift_pak {
    var res: UnsafeMutablePointer<Int8>
    var error: UnsafeMutablePointer<Int8>
    var transmitted: UnsafeMutablePointer<Int>
    var received: UnsafeMutablePointer<Int>
    let call: (UnsafeMutablePointer<Int8>, UnsafeMutablePointer<Int8>, UnsafeMutablePointer<Int>, UnsafeMutablePointer<Int>) -> Void
    var ok_to_ping: UnsafeMutablePointer<Bool>
}
*/

class PingHelper {
    static func ping(domain: String, controller: PingViewController, okToPing: UnsafeMutablePointer<Bool>) -> Int32 {
        var ret: Int32 = 0;
        let c: Int32 = 2
        let array: [String?] = ["", domain, nil]
        var cargs = array.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
        let res = UnsafeMutablePointer<Int8>.allocate(capacity: 10000)
        let err = UnsafeMutablePointer<Int8>.allocate(capacity: 10000)
        let transmitted = UnsafeMutablePointer<Int>.allocate(capacity: 10000)
        let received = UnsafeMutablePointer<Int>.allocate(capacity: 10000)
        
        ret = start_ping(c, &cargs, res, err, transmitted, received, controller.notify, okToPing);

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

                // No issue with probe
                tblData.append(
                    PingRow(
                        bytes: bytes,
                        from: from,
                        seq: seq,
                        ttl: ttl,
                        time: time
                    )
                )
            }
            else {
                // Issue with probe
                tblData.append(
                    PingRow(
                        bytes: -1,
                        from: String(row),
                        seq: i,
                        ttl: -1,
                        time: -1
                    )
                )
            }

            i=i+1
        }

        tblData.reverse()
        return tblData
    }
}
