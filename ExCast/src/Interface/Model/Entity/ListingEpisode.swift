//
//  ListingEpisode.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxDataSources

struct ListingEpisode: Equatable {
    let episode: Episode
    /// 再生中かどうか
    let isPlaying: Bool
    /// 現在の再生位置
    let currentPlaybackSec: Double?

    /// セル内に描画中の再生位置
    var displayingPlaybackSec: Double? {
        if let sec = self.currentPlaybackSec {
            return sec
        }

        if let sec = self.episode.playback?.playbackPositionSec {
            return Double(sec)
        }

        return nil
    }

    func startedPlay() -> ListingEpisode {
        return .init(episode: self.episode, isPlaying: true, currentPlaybackSec: self.currentPlaybackSec)
    }

    func finishedPlay() -> ListingEpisode {
        return .init(episode: self.episode, isPlaying: false, currentPlaybackSec: self.currentPlaybackSec)
    }
}

extension ListingEpisode: IdentifiableType {
    // MARK: - IndetifiableTyp

    typealias Identity = Episode.Identity

    var identity: String {
        return episode.identity
    }
}
