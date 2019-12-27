// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Podcast: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: PodcastObject) -> Self {
        return .init(
            feedUrl: URL(string: managedObject.feedUrl)!,
            meta: Channel.make(by: managedObject.meta!),
            episodes: managedObject.episodes.map { Episode.make(by: $0) }
        )
    }

    func asManagedObject() -> PodcastObject {
        let obj = PodcastObject()
        obj.feedUrl = feedUrl.absoluteString
        obj.meta = meta.asManagedObject()
        episodes.forEach { obj.episodes.append($0.asManagedObject()) }
        return obj
    }
}

final class PodcastObject: Object {
    @objc dynamic var feedUrl: String = ""
    @objc dynamic var meta: ChannelObject? = ChannelObject()
    let episodes: List<EpisodeObject> = List<EpisodeObject>()

    override static func primaryKey() -> String? {
        return "feedUrl"
    }
}
