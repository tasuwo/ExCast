// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import RealmSwift
@testable import Domain

extension ChannelOwner: Persistable {
    // MARK: - Persistable

    static func makePersistable(managedObject: ChannelOwnerObject) -> Self {
        return .init(
            name: managedObject.name,
            email: managedObject.email
        )
    }

    func asManagedObject() -> ChannelOwnerObject {
        let obj = ChannelOwnerObject()
        obj.name = name
        obj.email = email
        return obj
    }
}

final class ChannelOwnerObject: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
}
