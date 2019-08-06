//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class TraceRouteHelper {
    static func trace(domain: String, controller: TraceRouteViewController) {
        let c: Int32 = 2
        let array: [String?] = ["", domain, nil]
        var cargs = array.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
        let response = UnsafeMutablePointer<Int8>.allocate(capacity: 10000)
        start_trace_route(c, &cargs, response, controller.newTrace)
        
        for ptr in cargs {
            free(UnsafeMutablePointer(mutating: ptr))
        }
    }
    
    static func parseResponse(results: String) -> [TraceRouteRow] {
        var tblData: [TraceRouteRow] = []
        let rows = results.split(separator: "|")
        let regex = try? NSRegularExpression(
            pattern: "^\\s?([0-9]{1,})\\s+([a-zA-Z0-9-.()\\s]{1,})\\s+([0-9.]{1,}) ms\\s+([0-9.]{1,}) ms\\s+([0-9.]{1,}) ms$",
            options: NSRegularExpression.Options.caseInsensitive
        )

        if results.contains("cannot resolve") {
            return [TraceRouteRow(hop: 0, host: results, rtt1: -1, rtt2: -1, rtt3: -1)]
        }

        if results.contains("Request timeout") {
            return [TraceRouteRow(hop: 0, host: results, rtt1: -1, rtt2: -1, rtt3: -1)]
        }

        for row in rows {
            var hop = 0
            var host = "N/A"
            var rtt1 = 0.0
            var rtt2 = 0.0
            var rtt3 = 0.0
            let myrow = String(row) // deep copy
            let matches = regex!.matches(
                in: String(myrow),
                options: [],
                range: NSRange(location: 0, length: myrow.count)
            )

            if let match = matches.first {
                if let range = Range(match.range(at:1), in: String(myrow)) {
                    hop = Int(myrow[range]) ?? 0
                }

                if let range = Range(match.range(at:2), in: String(myrow)) {
                    host = String(myrow[range])
                }

                if let range = Range(match.range(at:3), in: String(myrow)) {
                    rtt1 = Double(myrow[range]) ?? 0
                }

                if let range = Range(match.range(at:4), in: String(myrow)) {
                    rtt2 = Double(myrow[range]) ?? 0
                }

                if let range = Range(match.range(at:5), in: String(myrow)) {
                    rtt3 = Double(myrow[range]) ?? 0.0
                }

                tblData.append(
                    TraceRouteRow(
                        hop: hop,
                        host: host,
                        rtt1: rtt1,
                        rtt2: rtt2,
                        rtt3: rtt3
                    )
                )
            }
        }

        return tblData
    }
}
