//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

class PingRow {
    var bytes: String
    var from: String
    var seq: String
    var ttl: String
    var time: String
    
    init(bytes: String?, from: String?, seq: String?, ttl: String?, time: String?) {
        if let bytes = bytes {
            self.bytes = bytes
        }
        else {
            self.bytes = "--"
        }
        
        if let from = from {
            self.from = from
        }
        else {
            self.from = "--"
        }
        
        if let seq = seq {
            self.seq = seq
        }
        else {
            self.seq = "--"
        }
        
        if let ttl = ttl {
            self.ttl = ttl
        }
        else {
            self.ttl = "--"
        }
        
        if let time = time {
            self.time = time
        }
        else {
            self.time = "--"
        }
    }
}
