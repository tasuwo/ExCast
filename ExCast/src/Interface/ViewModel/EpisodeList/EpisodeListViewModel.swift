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
    private let gateway: PodcastGateway
    private let repository: PodcastRepository

    var show: Dynamic<Podcast.Show>
    var episodes: DynamicArray<Podcast.Episode>
    var playingEpisode: Dynamic<Podcast.Episode?>

    // MARK: - Initializer

    init(podcast: Podcast, gateway: PodcastGateway, repository: PodcastRepository) {
        self.feedUrl = podcast.show.feedUrl
        self.show = Dynamic(podcast.show)
        self.episodes = DynamicArray([])
        self.playingEpisode = Dynamic(nil)
        self.gateway = gateway
        self.repository = repository
        self.podcast = podcast
    }

    // MARK: - Methods

    func setup(with playingEpisode: Podcast.Episode?) {
        // 初回の View への同期、もっと綺麗な方法はないか
        self.show.value = podcast.show
        self.episodes.set(podcast.episodes)
        self.playingEpisode.value = playingEpisode
    }

    func loadIfNeeded(completion: @escaping (Bool) -> Void) {
        self.gateway.fetch(feed: self.feedUrl) { [unowned self] result in
            switch result {
            case .success(let fetchedPodcast):
                var isChanged = false

                if fetchedPodcast.show != self.show.value {
                    self.show.value = fetchedPodcast.show
                    isChanged = true
                }

                if fetchedPodcast.episodes != self.episodes.values {
                    self.episodes.set(fetchedPodcast.episodes)
                    isChanged = true
                }

                if isChanged {
                    try? self.repository.update(fetchedPodcast)
                }

                completion(true)
            case .failure(_):
                // TODO: Error handling
                completion(false)
            }
        }
    }

}
