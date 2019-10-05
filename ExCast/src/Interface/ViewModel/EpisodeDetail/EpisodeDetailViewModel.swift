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
        self.title = BehaviorRelay(value: episode.title)
        self.pubDate = BehaviorRelay(value: episode.pubDate)
        self.duration = BehaviorRelay(value: episode.duration ?? 0)
        self.thumbnail = BehaviorRelay(value: episode.artwork ?? show.artwork)
        self.description = BehaviorRelay(value: episode.description ?? "")
    }

    func layoutDescription() {
        self.description.accept(self.episode.description ?? "")
    }

}
