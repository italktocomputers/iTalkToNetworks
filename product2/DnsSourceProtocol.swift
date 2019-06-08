//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 Andrew Schools. All rights reserved.
//

import Foundation

protocol DnsSourceProtocol {
    func dnsLookUp(searchTerm: String, searchOptions: [String]) -> [DnsRow]
}
