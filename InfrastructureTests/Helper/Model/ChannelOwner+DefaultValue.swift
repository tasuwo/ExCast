// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension ChannelOwner {
    static func makeDefault(
        name: String = "",
        email: String = ""
    ) -> Self {
        return .init(
            name: name,
            email: email
        )
    }
}
