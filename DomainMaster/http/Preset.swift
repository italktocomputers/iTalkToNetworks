//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

class Preset: Codable {
    var name: String
    var url: URL
    var port: Int
    var method: String
    var payload: String
    var headers: [String:String]
    
    init(name: String, url: URL, port: Int, method: String, payload: String, headers: [String:String]) {
        self.name = name
        self.url = url
        self.port = port
        self.method = method
        self.payload = payload
        self.headers = headers
    }
    
    func serialize() -> Data? {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(self)
            return data
        }
        catch {
           print("Cannot serialize data!")
        }
        
        return nil
    }
}
