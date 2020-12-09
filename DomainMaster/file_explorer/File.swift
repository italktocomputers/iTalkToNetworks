//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

class File {
    var fileName: String
    var fileSize: String
    var fileKind: String
    var fileAdded: String
    
    init(fileName: String, fileSize: String, fileKind: String, fileAdded: String) {
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileKind = fileKind
        self.fileAdded = fileAdded
    }
    
    static func initFromArray(arr: Array<String>) -> [File] {
        var newArr: [File] = []
        
        for i in arr {
            newArr.append(File(fileName: i, fileSize: "0", fileKind: "0", fileAdded: "0"))
        }
        
        return newArr
    }
}
