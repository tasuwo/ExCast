// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Item {
    static func makeDefault(
        guid: String = "",
        guidIsPermaLink: Bool? = nil,
        title: String = "",
        subTitle: String? = nil,
        enclosure: Enclosure = Enclosure.makeDefault(),
        pubDate: Date? = nil,
        itemDescription: String? = nil,
        duration: Double? = nil,
        link: URL? = nil,
        artwork: URL? = nil
    ) -> Self {
        return .init(
            guid: guid,
            guidIsPermaLink: guidIsPermaLink,
            title: title,
            subTitle: subTitle,
            enclosure: enclosure,
            pubDate: pubDate,
            itemDescription: itemDescription,
            duration: duration,
            link: link,
            artwork: artwork
        )
    }
}
