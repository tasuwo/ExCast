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
    private let show: Podcast.Show
    private let episode: Podcast.Episode

    private(set) var title: BehaviorRelay<String>
    private(set) var pubDate: BehaviorRelay<Date?>
    private(set) var duration: BehaviorRelay<Double>
    private(set) var thumbnail: BehaviorRelay<URL?>
    private(set) var description: BehaviorRelay<String>

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
