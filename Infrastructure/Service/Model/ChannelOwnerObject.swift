// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Domain
import RealmSwift

extension ChannelOwner: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: ChannelOwnerObject) -> Self {
        return .init(
            name: managedObject.name,
            email: managedObject.email
        )
    }

    func asManagedObject() -> ChannelOwnerObject {
        let obj = ChannelOwnerObject()
        obj.name = self.name
        obj.email = self.email
        return obj
    }
}

final class ChannelOwnerObject: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
}
