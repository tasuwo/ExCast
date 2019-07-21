//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class PodcastGateway: PodcastRepository {

    private let session: URLSession!
    private let factory: PodcastFactory!
    private let repository: LocalRespository!
    
    private static let key = "Podcast"
    
    init(session: URLSession, factory: PodcastFactory, repository: LocalRespository) {
        self.session = session
        self.factory = factory
        self.repository = repository
    }

    func fetchAll(_ completion: @escaping (Result<[Podcast], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let podcasts = self.repository.fetch(forKey: PodcastGateway.key) as [Podcast]? ?? []
            completion(Result.success(podcasts))
        }
    }

    func fetch(feed: URL, _ completion: @escaping (Result<Podcast, Error>) -> Void) {
        let podcasts = self.repository.fetch(forKey: PodcastGateway.key) as [Podcast]? ?? []

        if let podcast = podcasts.first(where: { $0.show.feedUrl == feed }) {
            completion(Result.success(podcast))
            return
        }

        let task = self.session.dataTask(with: feed) { [unowned self] (data, res, err) in
            if let error = err {
                completion(Result.failure(error))
                return
            }
            
            guard let response = res as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                // TODO:
                completion(Result.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            guard let xml = data else {
                // TODO: Error Handling
                completion(Result.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            switch self.factory.create(from: xml) {
            case .success(let podcast):
                completion(Result.success(podcast))
            case .failure(_):
                // TODO: Error handling
                completion(Result.failure(NSError(domain: "", code: -1, userInfo: nil)))
                break
            }
        }
        
        task.resume()
    }

    func insertIfNeeded(_ podcast: Podcast) {
        let podcasts = self.repository.fetch(forKey: PodcastGateway.key) as [Podcast]? ?? []

        if let _ = podcasts.first(where: { $0.show.feedUrl == podcast.show.feedUrl }) {
            return
        }

        self.repository.store(obj: podcasts + [podcast], forKey: PodcastGateway.key)
    }

    func insertShow(at index: Int, _ value: Podcast.Show) {
        var podcasts = self.repository.fetch(forKey: PodcastGateway.key) as [Podcast]? ?? []

        podcasts[index] = Podcast(show: value, episodes: [])

        self.repository.store(obj: podcasts, forKey: PodcastGateway.key)
    }

    func updateShow(at index: Int, _ value: Podcast.Show) {
        var podcasts = self.repository.fetch(forKey: PodcastGateway.key) as [Podcast]? ?? []

        podcasts[index] = Podcast(show: value, episodes: podcasts[index].episodes)

        self.repository.store(obj: podcasts, forKey: PodcastGateway.key)
    }

    func removeShow(at index: Int) {
        var podcasts = self.repository.fetch(forKey: PodcastGateway.key) as [Podcast]? ?? []

        podcasts.remove(at: index)

        self.repository.store(obj: podcasts, forKey: PodcastGateway.key)
    }

}
