//
//  EpisodePlayerInformationViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import RxRelay

class PlayerInformationViewModel {
    let show: Podcast.Show
    let episode: Podcast.Episode

    var showTitle: BehaviorRelay<String>
    var episodeTitle: BehaviorRelay<String>
    var thumbnail: BehaviorRelay<URL?>

    // MARK: - Lifecycle

    init(show: Podcast.Show, episode: Podcast.Episode) {
        self.show = show
        self.episode = episode

        self.showTitle = BehaviorRelay(value: show.title)
        self.episodeTitle = BehaviorRelay(value: episode.title)
        let artworkUrl = episode.artwork ?? show.artwork
        self.thumbnail = BehaviorRelay(value: artworkUrl)
    }
}
