// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Domain
import RealmSwift

extension Enclosure: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: EnclosureObject) -> Self {
        return .init(
            url: URL(string: managedObject.url)!,
            length: managedObject.length.value,
            type: FileFormat(rawValue: managedObject.type)!
        )
    }

    func asManagedObject() -> EnclosureObject {
        let obj = EnclosureObject()
        obj.url = self.url.absoluteString
        obj.length.value = self.length
        obj.type = self.type.rawValue
        return obj
    }
}

final class EnclosureObject: Object {
    @objc dynamic var url: String = ""
    let length: RealmOptional<Int> = RealmOptional<Int>()
    @objc dynamic var type: String = ""
}
