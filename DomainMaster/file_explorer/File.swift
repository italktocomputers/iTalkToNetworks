//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation
import AppKit

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
    
    static func initFromArray(fileManager: FileManager, arr: Array<String>, path: String) -> [File] {
        var newArr: [File] = []
        
        for i in arr {
            let attributes = getFileattributes(fileManager: fileManager, fileName: i, path: path)
            let size = attributes[FileAttributeKey.size] as! NSNumber
            let type = attributes[FileAttributeKey.type] as! String
            let date = attributes[FileAttributeKey.creationDate] as! Date
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            newArr.append(
                File(fileName: i, fileSize: size.stringValue, fileKind: type, fileAdded: formatter1.string(from: date))
            )
        }
        
        return newArr
    }
    
    static func getFileattributes(fileManager: FileManager, fileName: String, path: String) -> [FileAttributeKey: Any] {
        var attributes: [FileAttributeKey: Any] = [:]
        
        do {
            attributes = try fileManager.attributesOfItem(atPath: "\(path)/\(fileName)")
        }
        catch {
            print(error)
        }
        
        return attributes
    }
}
