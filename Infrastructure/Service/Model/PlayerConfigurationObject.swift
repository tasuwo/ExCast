// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import RealmSwift
@testable import Domain

extension PlayerConfiguration: Persistable {
    // MARK: - Persistable

    static func makePersistable(managedObject: PlayerConfigurationObject) -> Self {
        return .init(
            forwardSkipTime: managedObject.forwardSkipTime,
            backwardSkipTime: managedObject.backwardSkipTime
        )
    }

    func asManagedObject() -> PlayerConfigurationObject {
        let obj = PlayerConfigurationObject()
        obj.forwardSkipTime = forwardSkipTime
        obj.backwardSkipTime = backwardSkipTime
        return obj
    }
}

final class PlayerConfigurationObject: Object {
    @objc dynamic var forwardSkipTime: TimeInterval = 0
    @objc dynamic var backwardSkipTime: TimeInterval = 0
}
