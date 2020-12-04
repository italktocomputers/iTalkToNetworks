//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class TraceRouteHelper {
    static func trace(domain: String, stdOut: inout Pipe, stdErr: inout Pipe) -> Process {
        let wait = Helper.getSetting(name: "traceWait")
        let sourceAddress = Helper.getSetting(name: "traceSourceAddress")
        let port = Helper.getSetting(name: "tracePort")
        let maxHops = Helper.getSetting(name: "traceMaxHops")
        let numberOfProbes = Helper.getSetting(name: "traceNumberOfProbes")
        let typeOfService = Helper.getSetting(name: "traceTypeOfService")
        let bypassRouteTable = Helper.getSetting(name: "traceBypassRouteTable")
        
        var waitArg = ""
        var sourceAddressArg = ""
        var portArg = ""
        var maxHopsArg = ""
        var numberOfProbesArg = ""
        var typeOfServiceArg = ""
        var bypassRouteTableArg = ""
        
        if wait != "" {
            waitArg = "-w \(wait)"
        }
        
        if sourceAddress != "" {
            sourceAddressArg = "-s \(sourceAddress)"
        }
        
        if port != "" {
            portArg = "-p \(port)"
        }
        
        if maxHops != "" {
            maxHopsArg = "-m \(maxHops)"
        }
        
        if numberOfProbes != "" {
            numberOfProbesArg = "-q \(numberOfProbes)"
        }
        
        if typeOfService != "" {
            typeOfServiceArg = "-t \(typeOfService)"
        }
        
        if bypassRouteTable == "on" {
            bypassRouteTableArg = "-r"
        }
        
        return Helper.shell(stdOut: &stdOut, stdErr: &stdErr, "traceroute \(waitArg) \(sourceAddressArg) \(portArg) \(maxHopsArg) \(numberOfProbesArg) \(typeOfServiceArg) \(bypassRouteTableArg) \(domain)")
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
