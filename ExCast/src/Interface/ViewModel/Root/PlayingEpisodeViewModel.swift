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
    private(set) var playingEpisode: BehaviorRelay<EpisodeBelongsToShow?> = BehaviorRelay(value: nil)

    private(set) var isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var currentDuration: BehaviorRelay<Double?> = BehaviorRelay(value: nil)

    func set(id: Podcast.Identity, episode: Episode, belongsTo show: Show) {
        self.playingEpisode.accept(EpisodeBelongsToShow(id: id, episode: episode, show: show))
    }

    func clear() {
        self.playingEpisode.accept(nil)
    }
}
