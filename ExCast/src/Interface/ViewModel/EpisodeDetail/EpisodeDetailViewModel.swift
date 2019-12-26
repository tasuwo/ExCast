//
//  EpisodeDetailViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation
import RxRelay

class EpisodeDetailViewModel {
    private let show: Show
    private let episode: Episode

    private(set) var title: BehaviorRelay<String>
    private(set) var pubDate: BehaviorRelay<Date?>
    private(set) var duration: BehaviorRelay<Double>
    private(set) var thumbnail: BehaviorRelay<URL?>
    private(set) var description: BehaviorRelay<String>

    init(show: Show, episode: Episode) {
        self.show = show
        self.episode = episode
        title = BehaviorRelay(value: self.episode.meta.title)
        pubDate = BehaviorRelay(value: self.episode.meta.pubDate)
        duration = BehaviorRelay(value: self.episode.meta.duration ?? 0)
        thumbnail = BehaviorRelay(value: self.episode.meta.artwork ?? show.artwork)
        description = BehaviorRelay(value: self.episode.meta.itemDescription ?? "")
    }

    func layoutDescription() {
        description.accept(episode.meta.itemDescription ?? "")
    }
}
