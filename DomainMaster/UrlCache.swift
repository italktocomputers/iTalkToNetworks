//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

class UrlCache {
    static func add(url: String) {
        var add = true
        let defaults = UserDefaults.standard
        let urls = defaults.array(forKey: "urls")
        
        if var urls_arr = urls {
            for i in urls_arr {
                if i as! String == url {
                    add = false
                    break
                }
            }
            
            if add {
                urls_arr.append(url)
                defaults.set(urls_arr, forKey: "urls")
            }
        }
        else {
            var urls_arr: [String] = []
            urls_arr.append(url)
            defaults.set(urls_arr, forKey: "urls")
        }
    }
    
    static func get() -> [Any] {
        let defaults = UserDefaults.standard
        let urls = defaults.array(forKey: "urls")
        
        if let urls_arr = urls {
            return urls_arr
        }
        else {
            return []
        }
    }
}
