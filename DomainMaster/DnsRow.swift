//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

class DnsRow {
    var domain: String
    var ttl: String
    var type: String
    var ip: String
    
    init(domain: String?, ttl: String?, type: String?, ip: String?) {
        if let domain = domain {
            self.domain = domain
        }
        else {
            self.domain = "--"
        }
        
        if let ttl = ttl {
            self.ttl = ttl
        }
        else {
            self.ttl = "-1"
        }
        
        if let type = type {
            self.type = type
        }
        else {
            self.type = "--"
        }
        
        if let ip = ip {
            self.ip = ip
        }
        else {
            self.ip = "--"
        }
    }
}
