//
//  PodcastRepository.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RealmSwift
import RxSwift

public protocol PodcastRepositoryProtocol {
    func getAll() -> Observable<Result<[Podcast], Error>>
    func add(_ podcast: Podcast) -> Observable<Result<Podcast, Error>>
    func update(_ podcast: Podcast) -> Observable<Result<Podcast, Error>>
    func remove(_ podcast: Podcast) -> Observable<Result<Podcast, Error>>
}

public struct PodcastRepository: PodcastRepositoryProtocol {
    private let factory: PodcastFactoryProtocol.Type

    public init(factory: PodcastFactoryProtocol.Type) {
        self.factory = factory
    }

    public func getAll() -> Observable<Result<[Podcast], Error>> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                let realm = try! Realm()
                let podcasts = Array(realm.objects(PodcastObject.self)).map { Podcast.make(by: $0) }

                observer.onNext(.success(podcasts))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    public func add(_ podcast: Podcast) -> Observable<Result<Podcast, Error>> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(podcast.asManagedObject())

                    observer.onNext(.success(podcast))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    public func update(_ podcast: Podcast) -> Observable<Result<Podcast, Error>> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(podcast.asManagedObject())

                    observer.onNext(.success(podcast))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    public func remove(_ podcast: Podcast) -> Observable<Result<Podcast, Error>> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                let realm = try! Realm()
                try! realm.write {
                    guard let target = realm.object(ofType: PodcastObject.self, forPrimaryKey: podcast.feedUrl.absoluteString) else {
                        observer.onNext(.success(podcast))
                        observer.onCompleted()
                        return
                    }

                    realm.delete(target.meta!.owner!)
                    realm.delete(target.meta!)

                    for episode in target.episodes {
                        realm.delete(episode.meta!.enclosure!)
                        realm.delete(episode.meta!)
                        realm.delete(episode.playback!)
                        realm.delete(episode)
                    }
                    realm.delete(target.episodes)

                    realm.delete(target)

                    observer.onNext(.success(podcast))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
