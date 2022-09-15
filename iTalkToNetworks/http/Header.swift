import Foundation

class Header: NSObject, Codable {
    @objc dynamic var name: String
    @objc dynamic var value: String
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
