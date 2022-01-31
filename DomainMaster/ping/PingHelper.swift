//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class PingHelper {
    static func ping(domain: String, stdIn: inout Pipe, stdOut: inout Pipe, stdErr: inout Pipe) -> Process {
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
        
        var pingCountArg = ""
        var pingWaitArg = ""
        var pingTimeoutArg = ""
        var pingTTLArg = ""
        var interfaceAddressArg = ""
        var pingSourceAddressArg = ""
        var pingPreloadArg = ""
        var pingPacketSizeArg = ""
        var pingMaskArg = ""
        var pingIpsecPolicyArg = ""
        var pingSweepMaxSizeArg = ""
        var pingSweepMinSizeArg = ""
        var pingSweepIncSizeArg = ""
        var pingPatternArg = ""
        var pingTosArg = ""
        var pingBypassRouteArg = ""
        var pingSuppressLoopbackArg = ""
        var pingNoFragmentArg = ""
        var pingFloodArg = ""

        if pingCount != "" {
            pingCountArg = "-c \(pingCount)"
        }

        if pingWait != "" {
            pingWaitArg = "-W \(pingWait)"
        }

        if pingTimeout != "" {
            pingTimeoutArg = "-t \(pingTimeout)"
        }

        if pingTTL != "" {
            pingTTLArg = "-T \(pingTTL)"
        }

        if interfaceAddress != "" {
            interfaceAddressArg = "-I \(interfaceAddress)"
        }

        if pingSourceAddress != "" {
            pingSourceAddressArg = "-S \(pingSourceAddress)"
        }

        if pingPreload != "" {
            pingPreloadArg = "-l \(pingPreload)"
        }

        if pingPacketSize != "" {
            pingPacketSizeArg = "-s \(pingPacketSize)"
        }

        if pingMask != "" {
            pingMaskArg = "-M \(pingMask)"
        }

        if pingIpsecPolicy != "" {
            pingIpsecPolicyArg = "-P \(pingIpsecPolicy)"
        }

        if pingSweepMaxSize != "" {
            pingSweepMaxSizeArg = "-G \(pingSweepMaxSize)"
        }

        if pingSweepMinSize != "" {
            pingSweepMinSizeArg = "-g \(pingSweepMinSize)"
        }

        if pingSweepIncSize != "" {
            pingSweepIncSizeArg = "-h \(pingSweepIncSize)"
        }

        if pingPattern != "" {
            pingPatternArg = "-p \(pingPattern)"
        }

        if pingTos != "" {
            pingTosArg = "-z \(pingTos)"
        }

        if pingBypassRoute != "off" {
            pingBypassRouteArg = "-r"
        }

        if pingNoFragment != "off" {
            pingSuppressLoopbackArg = "-D"
        }

        if pingSuppressLoopback != "off" {
            pingNoFragmentArg = "-L"
        }

        if pingFlood != "off" {
            pingFloodArg = "-f"
        }
        
        return Helper.shell(stdIn: &stdIn, stdOut: &stdOut, stdErr: &stdErr, "ping \(pingCountArg) \(pingWaitArg) \(pingTimeoutArg) \(pingTTLArg) \(interfaceAddressArg) \(pingSourceAddressArg) \(pingPreloadArg) \(pingPacketSizeArg) \(pingMaskArg) \(pingIpsecPolicyArg) \(pingSweepMaxSizeArg) \(pingSweepMinSizeArg) \(pingSweepIncSizeArg) \(pingPatternArg) \(pingTosArg) \(pingBypassRouteArg) \(pingSuppressLoopbackArg) \(pingNoFragmentArg) \(pingFloodArg) \(domain)")
    }
    
    static func parseFinalResponse(results: String) -> PingStatistics {
        var transmitted = 0
        var received = 0
        var lossed = 0.0
        var min = 0.0
        var max = 0.0
        var avg = 0.0
        var stddev = 0.0
        
        // --- www.google.com ping statistics ---
        // 10 packets transmitted, 10 packets received, 0.0% packet loss
        // round-trip min/avg/max/stddev = 28.650/31.573/35.965/2.064 ms
        let regex = try? NSRegularExpression(
            pattern: "^\n.*\n([0-9]{1,}) packets transmitted, ([0-9]{1,}) packets received, ([0-9.]{1,})% packet loss\nround-trip min/avg/max/stddev = ([0-9.]{1,})/([0-9.]{1,})/([0-9.]{1,})/([0-9.]{1,}) ms$",
            options: NSRegularExpression.Options.caseInsensitive
        )
        
        let matches = regex!.matches(
            in: String(results),
            options: [],
            range: NSRange(location: 0, length: results.count)
        )

        if let match = matches.first {
            if let range = Range(match.range(at:1), in: String(results)) {
                transmitted = Int(results[range]) ?? 0
            }

            if let range = Range(match.range(at:2), in: String(results)) {
                received = Int(results[range]) ?? 0
            }

            if let range = Range(match.range(at:3), in: String(results)) {
                lossed = Double(results[range]) ?? 0
            }
            
            if let range = Range(match.range(at:4), in: String(results)) {
                avg = Double(results[range]) ?? 0
            }
            
            if let range = Range(match.range(at:5), in: String(results)) {
                min = Double(results[range]) ?? 0
            }
            
            if let range = Range(match.range(at:6), in: String(results)) {
                max = Double(results[range]) ?? 0
            }
            
            if let range = Range(match.range(at:7), in: String(results)) {
                stddev = Double(results[range]) ?? 0
            }
        }
        
        return PingStatistics(
            transmitted: transmitted,
            received: received,
            lossed: lossed,
            min: min,
            max: max,
            average: avg,
            stddev: stddev
        )
    }

    static func parseResponse(results: String) -> PingRow? {
        let regex = try? NSRegularExpression(
            pattern: "^([0-9]{1,}) bytes from ([0-9.]{1,}): icmp_seq=([0-9]{1,}) ttl=([0-9]{1,}) time=([0-9.]{1,}) ms$",
            options: NSRegularExpression.Options.caseInsensitive
        )

        // Default values
        var bytes = 0
        var from = "N/A"
        var seq = 0
        var ttl = 0
        var time = 0.0
    
        let matches = regex!.matches(
            in: String(results),
            options: [],
            range: NSRange(location: 0, length: results.count)
        )

        if let match = matches.first {
            if let range = Range(match.range(at:1), in: String(results)) {
                bytes = Int(results[range]) ?? 0
            }

            if let range = Range(match.range(at:2), in: String(results)) {
                from = String(results[range])
            }

            if let range = Range(match.range(at:3), in: String(results)) {
                seq = Int(results[range]) ?? 0
            }

            if let range = Range(match.range(at:4), in: String(results)) {
                ttl = Int(results[range]) ?? 0
            }

            if let range = Range(match.range(at:5), in: String(results)) {
                time = Double(results[range]) ?? 0.0
            }

            // No issue with probe
            return PingRow(
                bytes: bytes,
                from: from,
                seq: seq,
                ttl: ttl,
                time: time
            )
        }
        else {
            return nil
        }
    }
}
