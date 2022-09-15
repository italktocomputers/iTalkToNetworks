//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

import Foundation

protocol FileExplorerProtocol {
    func allowSelectDirectory() -> Bool
    func allowSelectFile() -> Bool
    func fileSelected(path: String, file: File)
}
