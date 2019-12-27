// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Episode {
    static func makeDefault(
        id: String = "",
        meta: Item = Item.makeDefault(),
        playback: Playback? = nil
    ) -> Self {
        return .init(
            id: id,
            meta: meta,
            playback: playback
        )
    }
}
