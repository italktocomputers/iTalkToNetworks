//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class TraceRouteHelper {
    /*
    static func trace(domain: String) -> [TraceRouteRow] {
        //let timeout = Helper.getSetting(name: "pingTimeout")
        let fileManager = FileManager.default
        let path = fileManager.currentDirectoryPath
        let results = Helper.shell("\(path)/traceroute \(domain)")
        return parseResponse(results: results)
    }
    */

    static func trace(domain: String) -> [TraceRouteRow] {
        let c: Int32 = 2
        let array: [String?] = ["", "www.google.com", nil]
        var cargs = array.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }

        let result = start_trace_route(c, &cargs)

        for ptr in cargs {
            free(UnsafeMutablePointer(mutating: ptr))
        }

        //return parseResponse(results: String(cString: result))

        return [TraceRouteRow(hop: 1, host: "", rtt1: 1.0, rtt2: 1.0, rtt3: 1.0)]
    }

    /*
     traceroute to google.com (172.217.3.110), 64 hops max, 52 byte packets
     1  10.0.0.1 (10.0.0.1)  4.552 ms  5.669 ms  5.038 ms
     2  96.120.70.61 (96.120.70.61)  14.243 ms  17.746 ms  16.018 ms
     3  96.108.100.1 (96.108.100.1)  15.571 ms  15.058 ms  16.149 ms
     4  96.108.46.106 (96.108.46.106)  16.663 ms  13.859 ms  14.712 ms
     5  be-315-ar01.needham.ma.boston.comcast.net (96.108.46.117)  22.021 ms  20.559 ms  21.353 ms
     6  be-7015-cr02.newyork.ny.ibone.comcast.net (68.86.90.217)  27.535 ms  26.534 ms  27.525 ms
     7  be-10381-pe02.111eighthave.ny.ibone.comcast.net (68.86.86.250)  31.563 ms  26.649 ms  26.130 ms
     8  50.242.150.62 (50.242.150.62)  24.679 ms  24.890 ms  23.321 ms
     9  108.170.248.97 (108.170.248.97)  26.695 ms
     108.170.248.33 (108.170.248.33)  27.375 ms  27.335 ms
     10  209.85.253.189 (209.85.253.189)  27.443 ms
     209.85.244.65 (209.85.244.65)  28.556 ms  26.029 ms
     11  lga34s18-in-f14.1e100.net (172.217.3.110)  26.150 ms  27.296 ms  26.213 ms
     */
    static func parseResponse(results: String) -> [TraceRouteRow] {
        var tblData: [TraceRouteRow] = []
        let rows = results.split(separator: "\n")
        let regex = try? NSRegularExpression(
            pattern: "^([0-9]{1,}) ([a-zA-Z0-9-.()]{1,})  ([0-9.]{1,}) ms ([0-9.]{1,}) ms ([0-9.]{1,}) ms$",
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
