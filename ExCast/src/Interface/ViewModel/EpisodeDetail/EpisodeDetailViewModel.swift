//
//  EpisodeDetailViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class EpisodeDetailViewModel {

    let show: Podcast.Show
    let episode: Podcast.Episode

    var title: Dynamic<String>
    var pubDate: Dynamic<Date?>
    var duration: Dynamic<Double>
    var thumbnail: Dynamic<URL?>
    var description: Dynamic<String>

    init(show: Podcast.Show, episode: Podcast.Episode) {
        self.show = show
        self.episode = episode
        self.title = Dynamic(episode.title)
        self.pubDate = Dynamic(episode.pubDate)
        self.duration = Dynamic(episode.duration ?? 0)
        self.thumbnail = Dynamic(episode.artwork ?? show.artwork)
        self.description = Dynamic(episode.description ?? "")
    }

    func setup() {
        self.title.value = self.episode.title
        self.pubDate.value = self.episode.pubDate
        self.duration.value = self.episode.duration ?? 0
        self.thumbnail.value = self.episode.artwork ?? self.show.artwork
        self.description.value = self.episode.description ?? ""
    }

}
