// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Domain
import RealmSwift

extension PlayerConfiguration: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: PlayerConfigurationObject) -> Self {
        return .init(
            forwardSkipTime: managedObject.forwardSkipTime,
            backwardSkipTime: managedObject.backwardSkipTime
        )
    }

    func asManagedObject() -> PlayerConfigurationObject {
        let obj = PlayerConfigurationObject()
        obj.forwardSkipTime = self.forwardSkipTime
        obj.backwardSkipTime = self.backwardSkipTime
        return obj
    }
}

final class PlayerConfigurationObject: Object {
    @objc dynamic var forwardSkipTime: TimeInterval = 0
    @objc dynamic var backwardSkipTime: TimeInterval = 0
}
