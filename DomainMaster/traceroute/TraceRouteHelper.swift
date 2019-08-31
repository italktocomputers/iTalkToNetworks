//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class TraceRouteHelper {
    static func trace(domain: String, res: UnsafeMutablePointer<CChar>, err: UnsafeMutablePointer<CChar>, okToTrace: UnsafeMutablePointer<Bool>, notify: @escaping (UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<CChar>?) -> ()) -> Int32 {
        var ret: Int32 = 0
        let c: Int32
        
        let wait = Helper.getSetting(name: "traceWait")
        let sourceAddress = Helper.getSetting(name: "traceSourceAddress")
        let port = Helper.getSetting(name: "tracePort")
        let maxHops = Helper.getSetting(name: "traceMaxHops")
        let numberOfProbes = Helper.getSetting(name: "traceNumberOfProbes")
        let typeOfService = Helper.getSetting(name: "traceTypeOfService")
        let bypassRouteTable = Helper.getSetting(name: "traceBypassRouteTable")
        
        var uargs: [String?] = []
        
        uargs.append("")
        
        if wait != "" {
            uargs.append("-w")
            uargs.append(wait)
        }
        
        if sourceAddress != "" {
            uargs.append("-s")
            uargs.append(sourceAddress)
        }
        
        if port != "" {
            uargs.append("-p")
            uargs.append(port)
        }
        
        if maxHops != "" {
            uargs.append("-m")
            uargs.append(maxHops)
        }
        
        if numberOfProbes != "" {
            uargs.append("-q")
            uargs.append(numberOfProbes)
        }
        
        if typeOfService != "" {
            uargs.append("-t")
            uargs.append(typeOfService)
        }
        
        if bypassRouteTable == "on" {
            uargs.append("-r")
        }
        
        uargs.append(domain)
        uargs.append(nil)
        
        c = Int32(uargs.count - 1)
        
        var cargs = uargs.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
        
        ret = start_trace_route(c, &cargs, res, err, okToTrace, notify)
        
        for ptr in cargs {
            free(UnsafeMutablePointer(mutating: ptr))
        }
        
        return ret
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

        var i=0
        for row in rows {
            print(row)
            var hop = i
            var host = "***"
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
            
            i=i+1
        }

        return tblData
    }
}
