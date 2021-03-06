//
//  EpisodePlayerInformationViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation
import RxRelay

class PlayerInformationViewModel {
    let id: Podcast.Identity
    let show: Show
    let episode: Episode

    private(set) var showTitle: BehaviorRelay<String>
    private(set) var episodeTitle: BehaviorRelay<String>
    private(set) var thumbnail: BehaviorRelay<URL?>

    // MARK: - Lifecycle

    init(id: Podcast.Identity, show: Show, episode: Episode) {
        self.id = id
        self.show = show
        self.episode = episode

        showTitle = BehaviorRelay(value: show.title)
        episodeTitle = BehaviorRelay(value: episode.meta.title)
        let artworkUrl = episode.meta.artwork ?? show.artwork
        thumbnail = BehaviorRelay(value: artworkUrl)
    }
}
