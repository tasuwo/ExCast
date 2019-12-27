// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain
import RealmSwift

extension Playback {
    static func makeDefault(
        playbackPositionSec: Int? = nil
    ) -> Self {
        return .init(
            playbackPositionSec: playbackPositionSec
        )
    }
}
