// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Playback: Persistable {
    // MARK: - Persistable

    static func make(by managedObject: PlaybackObject) -> Self {
        return .init(
            playbackPositionSec: managedObject.playbackPositionSec.value
        )
    }

    func asManagedObject() -> PlaybackObject {
        let obj = PlaybackObject()
        obj.playbackPositionSec.value = playbackPositionSec
        return obj
    }
}

final class PlaybackObject: Object {
    let playbackPositionSec: RealmOptional<Int> = RealmOptional<Int>()
}
