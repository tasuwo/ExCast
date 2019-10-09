//
//  EpisodeDetailViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import RxRelay

class EpisodeDetailViewModel {
    let show: Podcast.Show
    let episode: Podcast.Episode

    var title: BehaviorRelay<String>
    var pubDate: BehaviorRelay<Date?>
    var duration: BehaviorRelay<Double>
    var thumbnail: BehaviorRelay<URL?>
    var description: BehaviorRelay<String>

    init(show: Podcast.Show, episode: Podcast.Episode) {
        self.show = show
        self.episode = episode
        title = BehaviorRelay(value: episode.title)
        pubDate = BehaviorRelay(value: episode.pubDate)
        duration = BehaviorRelay(value: episode.duration ?? 0)
        thumbnail = BehaviorRelay(value: episode.artwork ?? show.artwork)
        description = BehaviorRelay(value: episode.description ?? "")
    }

    func layoutDescription() {
        description.accept(episode.description ?? "")
    }
}
