//
//  EpisodeBelongsToShow.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation

struct PlayingEpisode {
    let id: Podcast.Identity
    let episode: Episode
    let show: Show
    let currentPlaybackSec: Double?

    func updated(playbackSec: Double?) -> Self {
        .init(id: self.id, episode: self.episode, show: self.show, currentPlaybackSec: playbackSec)
    }
}
