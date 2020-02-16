//
//  EpisodeDetailViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation
import RxCocoa

protocol EpisodeDetailViewModelType {
    var inputs: EpisodeDetailViewModelInputs { get }
    var outputs: EpisodeDetailViewModelOutputs { get }
}

protocol EpisodeDetailViewModelInputs {
    func layoutDescription()
}

protocol EpisodeDetailViewModelOutputs {
    var title: Driver<String> { get }
    var pubDate: Driver<Date?> { get }
    var duration: Driver<Double> { get }
    var thumbnail: Driver<URL?> { get }
    var description: Driver<String> { get }
}

class EpisodeDetailViewModel: EpisodeDetailViewModelType, EpisodeDetailViewModelInputs, EpisodeDetailViewModelOutputs {
    // MARK: - EpisodeDetailViewModelType

    var inputs: EpisodeDetailViewModelInputs { return self }
    var outputs: EpisodeDetailViewModelOutputs { return self }

    // MARK: - EpisodeDetailViewModelInputs

    func layoutDescription() {
        self._description.accept(episode.meta.itemDescription ?? "")
    }

    // MARK: - EpisodeDetailViewModelOutputs

    let title: Driver<String>
    let pubDate: Driver<Date?>
    let duration: Driver<Double>
    let thumbnail: Driver<URL?>
    let description: Driver<String>

    // MARK: - Privates

    private let show: Show
    private let episode: Episode
    private let _title: BehaviorRelay<String>
    private let _pubDate: BehaviorRelay<Date?>
    private let _duration: BehaviorRelay<Double>
    private let _thumbnail: BehaviorRelay<URL?>
    private let _description: BehaviorRelay<String>

    // MARK: - Lifecycle

    init(show: Show, episode: Episode) {
        self.show = show
        self.episode = episode
        self._title = BehaviorRelay(value: self.episode.meta.title)
        self._pubDate = BehaviorRelay(value: self.episode.meta.pubDate)
        self._duration = BehaviorRelay(value: self.episode.meta.duration ?? 0)
        self._thumbnail = BehaviorRelay(value: self.episode.meta.artwork ?? show.artwork)
        self._description = BehaviorRelay(value: self.episode.meta.itemDescription ?? "")
        self.title = self._title.asDriver()
        self.pubDate = self._pubDate.asDriver()
        self.duration = self._duration.asDriver()
        self.thumbnail = self._thumbnail.asDriver()
        self.description = self._description.asDriver()
    }
}
