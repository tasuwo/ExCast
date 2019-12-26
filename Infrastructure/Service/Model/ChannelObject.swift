// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import RealmSwift
@testable import Domain

extension Channel: Persistable {
    // MARK: - Persistable

    static func makePersistable(managedObject: ChannelObject) -> Self {
        return .init(
            feedUrl: URL(string: managedObject.feedUrl)!,
            title: managedObject.title,
            showDescription: managedObject.showDescription,
            artwork: URL(string: managedObject.artwork)!,
            categories: Array(managedObject.categories),
            explicit: managedObject.explicit,
            language: Language(rawValue: managedObject.language)!,
            author: managedObject.author,
            site: managedObject.site != nil ? URL(string: managedObject.site!)! : nil,
            owner: managedObject.owner != nil ? ChannelOwner.makePersistable(managedObject: managedObject.owner!) : nil
        )
    }

    func asManagedObject() -> ChannelObject {
        let obj = ChannelObject()
        obj.feedUrl = feedUrl.absoluteString
        obj.title = title
        obj.showDescription = showDescription
        obj.artwork = artwork.absoluteString
        categories.forEach { obj.categories.append($0) }
        obj.explicit = explicit
        obj.language = language.rawValue
        obj.author = author
        obj.site = site?.absoluteString
        obj.owner = owner?.asManagedObject()
        return obj
    }
}

final class ChannelObject: Object {
    @objc dynamic var feedUrl: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var showDescription: String = ""
    @objc dynamic var artwork: String = ""
    let categories: List<String> = List<String>()
    @objc dynamic var explicit: Bool = false
    @objc dynamic var language: String = ""
    @objc dynamic var author: String?
    @objc dynamic var site: String?
    @objc dynamic var owner: ChannelOwnerObject?
}
