//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 Andrew Schools. All rights reserved.
//

import Foundation

class GoogleDnsDataSource : DnsSourceProtocol {
    func alertMalformedData() {
        Helper.dialogOK(title: "ERROR", text: "Malformed response from URL...  See logs for more information.")
    }
    
    func dnsLookUp(searchTerm: String, searchOptions: [String]) -> [DnsRow] {
        var dnsRows: [DnsRow] = []
        let url = URL(string: "https://dns.google.com/resolve?name=\(searchTerm)&type=ANY")
        
        do {
            let contents = try String(contentsOf: url!)
            let data = Data(contents.utf8)
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let answer = json["Answer"]
                
                for row in answer as! [Any] {
                    let x = row as! [String: Any]
                    dnsRows.append(
                        DnsRow(
                            domain: x["name"] as! String?,
                            ttl: x["TTL"] as! Int?,
                            type: DnsHelper.getResourceType(by: (x["type"] as! Int?)!),
                            ip: x["data"] as! String?
                        )
                    )
                }
            }
        }
        catch {
            Helper.dialogOK(title: "ERROR", text: "Cannot access URL...  See logs for more information.")
        }
        
        return dnsRows
    }
}
