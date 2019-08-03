//
//  PodcastRepository.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class PodcastRepositoryImpl: PodcastRepository {

    private let factory: PodcastFactory!
    private let repository: LocalRespository!

    private static let key = "Podcast"

    init(factory: PodcastFactory, repository: LocalRespository) {
        self.factory = factory
        self.repository = repository
    }

    func fetchAll(_ completion: @escaping (Result<[Podcast], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []
            completion(Result.success(podcasts))
        }
    }

    func add(_ podcast: Podcast) {
        let podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []

        if let _ = podcasts.first(where: { $0.show.feedUrl == podcast.show.feedUrl }) {
            return
        }

        self.repository.store(obj: podcasts + [podcast], forKey: PodcastRepositoryImpl.key)
    }

    func update(_ podcast: Podcast) {
        var podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []


        guard let target = podcasts.first(where: { $0.show.feedUrl == podcast.show.feedUrl }),
            let index = podcasts.firstIndex(of: target) else {
            return
        }

        podcasts[index] = podcast

        self.repository.store(obj: podcasts, forKey: PodcastRepositoryImpl.key)
    }

    func remove(_ podcast: Podcast) {
        var podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []

        guard let target = podcasts.first(where: { $0.show.feedUrl == podcast.show.feedUrl }),
            let index = podcasts.firstIndex(of: target) else {
            return
        }

        podcasts.remove(at: index)

        self.repository.store(obj: podcasts, forKey: PodcastRepositoryImpl.key)
    }

}

