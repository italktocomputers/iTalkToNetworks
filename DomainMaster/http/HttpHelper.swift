//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import CoreFoundation

class HttpHelper {
    static func parseResponse(results: [AnyHashable: Any]) -> [HeaderRow] {
        var headerRows: [HeaderRow] = []
        
        for item in results {
            headerRows.append(HeaderRow(name: item.key as! String, value: item.value as! String))
        }
        
        return headerRows
    }
}
