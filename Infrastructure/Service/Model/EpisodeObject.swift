// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import RealmSwift
@testable import Domain

extension Episode: Persistable {
    // MARK: - Persistable

    static func makePersistable(managedObject: EpisodeObject) -> Self {
        return .init(
            id: managedObject.id,
            meta: Item.makePersistable(managedObject: managedObject.meta!),
            playback: managedObject.playback != nil ? Playback.makePersistable(managedObject: managedObject.playback!) : nil
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
