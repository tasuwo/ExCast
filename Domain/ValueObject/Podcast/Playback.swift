//
//  Playback.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/07.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

// sourcery: model
/**
 * 再生情報
 */
public struct Playback: Codable, Equatable {
    /// 再生位置. 再生していない, あるいは再生を終えている場合は nil
    public let playbackPositionSec: Int?

    // MARK: - Lifecycle

    public init(playbackPositionSec: Int?) {
        self.playbackPositionSec = playbackPositionSec
    }
}

extension Playback {
    public static func defaultValue() -> Playback {
        return .init(playbackPositionSec: nil)
    }
}
