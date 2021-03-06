// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Enclosure {
    static func makeDefault(
        url: URL = URL(string: "http://example.com")!,
        length: Int? = nil,
        type: FileFormat = .m4a
    ) -> Self {
        return .init(
            url: url,
            length: length,
            type: type
        )
    }
}
