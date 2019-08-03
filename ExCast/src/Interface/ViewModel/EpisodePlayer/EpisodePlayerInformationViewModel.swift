//
//  EpisodePlayerInformationViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class EpisodePlayerInformationViewModel {
    let show: Podcast.Show
    let episode: Podcast.Episode

    var showTitle: Dynamic<String>
    var episodeTitle: Dynamic<String>
    var thumbnail: Dynamic<URL?>

    init(show: Podcast.Show, episode: Podcast.Episode) {
        self.show = show
        self.episode = episode

        self.showTitle = Dynamic(show.title)
        self.episodeTitle = Dynamic(episode.title)
        let artworkUrl = episode.artwork ?? show.artwork
        self.thumbnail = Dynamic(artworkUrl)
    }

    // MARK: - Methods

    func setup() {
        // TODO: 初回の同期を綺麗にする
        self.showTitle.value = show.title
        self.episodeTitle.value = episode.title
        let artworkUrl = self.episode.artwork ?? self.show.artwork
        self.thumbnail.value = artworkUrl
    }
}
