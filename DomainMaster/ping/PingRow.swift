//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

class PingRow {
    var bytes: Int
    var from: String
    var seq: Int
    var ttl: Int
    var time: Double
    
    init(bytes: Int?, from: String?, seq: Int?, ttl: Int?, time: Double?) {
        if let bytes = bytes {
            self.bytes = bytes
        }
        else {
            self.bytes = 0
        }
        
        if let from = from {
            self.from = from
        }
        else {
            self.from = "N/A"
        }
        
        if let seq = seq {
            self.seq = seq
        }
        else {
            self.seq = 0
        }
        
        if let ttl = ttl {
            self.ttl = ttl
        }
        else {
            self.ttl = 0
        }
        
        if let time = time {
            self.time = time
        }
        else {
            self.time = 0.0
        }
    }
}
