//
//  EpisodeListViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class EpisodeListViewModel {
    private let feedUrl: URL
    private let podcast: Podcast
    private let repository: PodcastRepository

    var show: Dynamic<Podcast.Show>
    var episodes: DynamicArray<Podcast.Episode>

    // MARK: - Initializer

    init(podcast: Podcast, repository: PodcastRepository) {
        self.feedUrl = podcast.show.feedUrl
        self.show = Dynamic(podcast.show)
        self.episodes = DynamicArray([])
        self.repository = repository

        self.podcast = podcast
    }

    // MARK: - Methods

    func setup() {
        // 初回の View への同期、もっと綺麗な方法はないか
        self.show.value = podcast.show
    }

    func loadIfNeeded() {
        self.repository.fetch(feed: self.feedUrl) { [unowned self] result in
            switch result {
            case .success(let fetchedPodcast):
                if fetchedPodcast.show != self.show.value {
                    self.show.value = fetchedPodcast.show
                }

                if fetchedPodcast.episodes != self.episodes.value {
                    self.episodes.set(fetchedPodcast.episodes)
                }
            case .failure(_): break
                // TODO: Error handling
            }
        }
    }

}
