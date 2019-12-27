// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Episode: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: EpisodeObject) -> Self {
        return .init(
            id: managedObject.id,
            meta: Item.make(by: managedObject.meta!),
            playback: managedObject.playback != nil ? Playback.make(by: managedObject.playback!) : nil
        )
    }

    func asManagedObject() -> EpisodeObject {
        let obj = EpisodeObject()
        obj.id = id
        obj.meta = meta.asManagedObject()
        obj.playback = playback?.asManagedObject()
        return obj
    }
}

final class EpisodeObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var meta: ItemObject? = ItemObject()
    @objc dynamic var playback: PlaybackObject?

    override static func primaryKey() -> String? {
        return "id"
    }
}
