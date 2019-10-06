//
//  PodcastRepository.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxSwift

protocol PodcastRepository {
    func getAll() -> Observable<Result<[Podcast], Error>>
    func add(_ podcast: Podcast) -> Observable<Result<Podcast, Error>>
    func update(_ podcast: Podcast) -> Observable<Result<Podcast, Error>>
    func remove(_ podcast: Podcast) -> Observable<Result<Podcast, Error>>
}

struct PodcastRepositoryImpl: PodcastRepository {

    private let factory: PodcastFactory!
    private let repository: LocalRespository!

    private static let key = "Podcast"

    init(factory: PodcastFactory, repository: LocalRespository) {
        self.factory = factory
        self.repository = repository
    }

    func getAll() -> Observable<Result<[Podcast], Error>> {
        return Observable.create { observer in
            let podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []
            observer.onNext(.success(podcasts))
            observer.onCompleted()
            return Disposables.create()
        }
    }

    func add(_ podcast: Podcast) -> Observable<Result<Podcast, Error>> {
        return Observable.create { [self] observer in
            let podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []

            if let _ = podcasts.first(where: { $0.show.feedUrl == podcast.show.feedUrl }) {
                observer.onNext(.success(podcast))
                observer.onCompleted()
                return Disposables.create()
            }

            self.repository.store(obj: podcasts + [podcast], forKey: PodcastRepositoryImpl.key)
            observer.onNext(.success(podcast))
            observer.onCompleted()
            return Disposables.create()
        }
    }

    func update(_ podcast: Podcast) -> Observable<Result<Podcast, Error>> {
        return Observable.create { observer in
            var podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []

            guard let target = podcasts.first(where: { $0.show.feedUrl == podcast.show.feedUrl }),
                let index = podcasts.firstIndex(of: target) else {
                    observer.onNext(.success(podcast))
                    observer.onCompleted()
                    return Disposables.create()
            }

            podcasts[index] = podcast

            self.repository.store(obj: podcasts, forKey: PodcastRepositoryImpl.key)
            observer.onNext(.success(podcast))
            observer.onCompleted()
            return Disposables.create()
        }
    }

    func remove(_ podcast: Podcast) -> Observable<Result<Podcast, Error>> {
        return Observable.create { observer in
            var podcasts = self.repository.fetch(forKey: PodcastRepositoryImpl.key) as [Podcast]? ?? []

            guard let target = podcasts.first(where: { $0.show.feedUrl == podcast.show.feedUrl }),
                let index = podcasts.firstIndex(of: target) else {
                    observer.onNext(.success(podcast))
                    observer.onCompleted()
                    return Disposables.create()
            }

            podcasts.remove(at: index)

            self.repository.store(obj: podcasts, forKey: PodcastRepositoryImpl.key)
            observer.onNext(.success(podcast))
            observer.onCompleted()
            return Disposables.create()
        }
    }

}

