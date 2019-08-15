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
        var ret: Int32 = 0
        let c: Int32 = 6

        let pingCount = Helper.getSetting(name: "pingCount")
        let pingWait = Helper.getSetting(name: "pingWait")
        let pingTimeout = Helper.getSetting(name: "pingTimeout")
        let pingTTL = Helper.getSetting(name: "pingTTL")
        let interfaceAddress = Helper.getSetting(name: "pingInterfaceAddress")
        let pingSourceAddress = Helper.getSetting(name: "pingSourceAddress")
        let pingPreload = Helper.getSetting(name: "pingPreload")
        let pingPacketSize = Helper.getSetting(name: "pingPacketSize")
        let pingMask = Helper.getSetting(name: "pingMask")
        let pingIpsecPolicy = Helper.getSetting(name: "pingIpsecPolicy")
        let pingSweepMaxSize = Helper.getSetting(name: "pingSweepMaxSize")
        let pingSweepMinSize = Helper.getSetting(name: "pingSweepMinSize")
        let pingSweepIncSize = Helper.getSetting(name: "pingSweepIncSize")
        let pingPattern = Helper.getSetting(name: "pingPattern")
        let pingTos = Helper.getSetting(name: "pingTos")

        let pingBypassRoute = Helper.getSetting(name: "pingBypassRoute")
        let pingSuppressLoopback = Helper.getSetting(name: "pingSuppressLoopback")
        let pingNoFragment = Helper.getSetting(name: "pingNoFragment")
        let pingFlood = Helper.getSetting(name: "pingFlood")
        
        var uargs: [String?] = []

        uargs.append("")

        if pingCount != "" {
            uargs.append("-c")
            uargs.append(pingCount)
        }

        if pingWait != "" {
            uargs.append("-W")
            uargs.append(pingWait)
        }

        if pingTimeout != "" {
            uargs.append("-t")
            uargs.append(pingTimeout)
        }

        if pingTTL != "" {
            uargs.append("-T")
            uargs.append(pingTTL)
        }

        if interfaceAddress != "" {
            uargs.append("-I")
            uargs.append(interfaceAddress)
        }

        if pingSourceAddress != "" {
            uargs.append("-S")
            uargs.append(pingSourceAddress)
        }

        if pingPreload != "" {
            uargs.append("-l")
            uargs.append(pingPreload)
        }

        if pingPacketSize != "" {
            uargs.append("-s")
            uargs.append(pingPacketSize)
        }

        if pingMask != "" {
            uargs.append("-M")
            uargs.append(pingMask)
        }

        if pingIpsecPolicy != "" {
            uargs.append("-P")
            uargs.append(pingIpsecPolicy)
        }

        if pingSweepMaxSize != "" {
            uargs.append("-G")
            uargs.append(pingSweepMaxSize)
        }

        if pingSweepMinSize != "" {
            uargs.append("-g")
            uargs.append(pingSweepMinSize)
        }

        if pingSweepIncSize != "" {
            uargs.append("-h")
            uargs.append(pingSweepIncSize)
        }

        if pingPattern != "" {
            uargs.append("-p")
            uargs.append(pingPattern)
        }

        if pingTos != "" {
            uargs.append("-z")
            uargs.append(pingTos)
        }

        if pingBypassRoute != "off" {
            uargs.append("-r")
        }

        if pingNoFragment != "off" {
            uargs.append("-D")
        }

        if pingSuppressLoopback != "off" {
            uargs.append("-L")
        }

        if pingFlood != "off" {
            uargs.append("-f")
        }

        uargs.append(domain)
        uargs.append(nil)

        var cargs = uargs.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
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
