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
    private(set) var playingEpisode: BehaviorRelay<Episode?> = BehaviorRelay(value: nil)

    func set(_ episode: Episode) {
        self.playingEpisode.accept(episode)
    }

    func clear() {
        self.playingEpisode.accept(nil)
    }
}
