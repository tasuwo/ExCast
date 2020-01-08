//
//  PlayingEpisodeViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxRelay

class PlayingEpisodeViewModel {
    private(set) var playingEpisode: BehaviorRelay<PlayingEpisode?> = BehaviorRelay(value: nil)
    private(set) var isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    func set(id: Podcast.Identity, episode: Episode, belongsTo show: Show, playbackSec: Double?) {
        self.playingEpisode.accept(PlayingEpisode(id: id, episode: episode, show: show, currentPlaybackSec: playbackSec))
    }

    func clear() {
        self.playingEpisode.accept(nil)
    }
}
