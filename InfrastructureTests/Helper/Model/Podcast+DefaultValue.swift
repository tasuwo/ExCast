// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Podcast {
    static func makeDefault(
        feedUrl: URL = URL(string: "http://example.com")!,
        meta: Channel = Channel.makeDefault(),
        episodes: [Episode] = []
    ) -> Self {
        return .init(
            feedUrl: feedUrl,
            meta: meta,
            episodes: episodes
        )
    }
}
