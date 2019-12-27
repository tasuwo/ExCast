// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Enclosure: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: EnclosureObject) -> Self {
        return .init(
            url: URL(string: managedObject.url)!,
            length: managedObject.length,
            type: FileFormat(rawValue: managedObject.type)!
        )
    }

    func asManagedObject() -> EnclosureObject {
        let obj = EnclosureObject()
        obj.url = url.absoluteString
        obj.length = length
        obj.type = type.rawValue
        return obj
    }
}

final class EnclosureObject: Object {
    @objc dynamic var url: String = ""
    @objc dynamic var length: Int = 0
    @objc dynamic var type: String = ""
}
