// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension PlayerConfiguration {
    static func makeDefault(
        forwardSkipTime: TimeInterval = 0,
        backwardSkipTime: TimeInterval = 0
    ) -> Self {
        return .init(
            forwardSkipTime: forwardSkipTime,
            backwardSkipTime: backwardSkipTime
        )
    }
}
