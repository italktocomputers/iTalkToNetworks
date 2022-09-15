//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

class TraceRouteRow {
    var hop: Int
    var host: String
    var rtt1: Double
    var rtt2: Double
    var rtt3: Double

    init(hop: Int?, host: String?, rtt1: Double?, rtt2: Double?, rtt3: Double?) {
        if let hop = hop {
            self.hop = hop
        }
        else {
            self.hop = 0
        }

        if let host = host {
            self.host = host
        }
        else {
            self.host = "N/A"
        }

        if let rtt1 = rtt1 {
            self.rtt1 = rtt1
        }
        else {
            self.rtt1 = 0.0
        }

        if let rtt2 = rtt2 {
            self.rtt2 = rtt2
        }
        else {
            self.rtt2 = 0.0
        }

        if let rtt3 = rtt3 {
            self.rtt3 = rtt3
        }
        else {
            self.rtt3 = 0.0
        }
    }
}
