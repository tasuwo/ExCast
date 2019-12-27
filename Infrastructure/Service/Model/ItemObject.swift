// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Item: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: ItemObject) -> Self {
        return .init(
            guid: managedObject.guid,
            guidIsPermaLink: managedObject.guidIsPermaLink.value,
            title: managedObject.title,
            subTitle: managedObject.subTitle,
            enclosure: Enclosure.make(by: managedObject.enclosure!),
            pubDate: managedObject.pubDate,
            itemDescription: managedObject.itemDescription,
            duration: managedObject.duration.value,
            link: managedObject.link != nil ? URL(string: managedObject.link!)! : nil,
            artwork: managedObject.artwork != nil ? URL(string: managedObject.artwork!)! : nil
        )
    }

    func asManagedObject() -> ItemObject {
        let obj = ItemObject()
        obj.guid = guid
        obj.guidIsPermaLink.value = guidIsPermaLink
        obj.title = title
        obj.subTitle = subTitle
        obj.enclosure = enclosure.asManagedObject()
        obj.pubDate = pubDate
        obj.itemDescription = itemDescription
        obj.duration.value = duration
        obj.link = link?.absoluteString
        obj.artwork = artwork?.absoluteString
        return obj
    }
}

final class ItemObject: Object {
    @objc dynamic var guid: String = ""
    let guidIsPermaLink: RealmOptional<Bool> = RealmOptional<Bool>()
    @objc dynamic var title: String = ""
    @objc dynamic var subTitle: String?
    @objc dynamic var enclosure: EnclosureObject? = EnclosureObject()
    @objc dynamic var pubDate: Date?
    @objc dynamic var itemDescription: String?
    let duration: RealmOptional<Double> = RealmOptional<Double>()
    @objc dynamic var link: String?
    @objc dynamic var artwork: String?
}
