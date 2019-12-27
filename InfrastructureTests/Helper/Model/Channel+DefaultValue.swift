// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Channel {
    static func makeDefault(
        feedUrl: URL = URL(string: "http://example.com")!,
        title: String = "",
        showDescription: String = "",
        artwork: URL = URL(string: "http://example.com")!,
        categories: [String] = [],
        explicit: Bool = false,
        language: Language = .English,
        author: String? = nil,
        site: URL? = nil,
        owner: ChannelOwner? = nil
    ) -> Self {
        return .init(
            feedUrl: feedUrl,
            title: title,
            showDescription: showDescription,
            artwork: artwork,
            categories: categories,
            explicit: explicit,
            language: language,
            author: author,
            site: site,
            owner: owner
        )
    }
}
