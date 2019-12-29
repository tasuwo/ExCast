//
//  PlayingEpisodeViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxRelay

struct PlayingEpisodeViewModel {
    private(set) var playingEpisode: BehaviorRelay<EpisodeBelongsToShow?> = BehaviorRelay(value: nil)

    func set(_ episode: Episode, belongsTo show: Show) {
        self.playingEpisode.accept(EpisodeBelongsToShow(episode: episode, show: show))
    }

    func clear() {
        self.playingEpisode.accept(nil)
    }
}
