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
    func getAll() -> Single<[Podcast]>
    func add(_ podcast: Podcast) -> Completable
    func update(_ podcast: Podcast) -> Completable
    func remove(_ podcast: Podcast) -> Completable
}

public struct PodcastRepository: PodcastRepositoryProtocol {
    private let factory: PodcastFactoryProtocol.Type
    private let queue: DispatchQueue = .init(label: "net.tasuwo.ExCast.Infrastructure.PodcastRepository")

    public init(factory: PodcastFactoryProtocol.Type) {
        self.factory = factory
    }

    public func getAll() -> Single<[Podcast]> {
        return Single.create(subscribe: { observer in
            self.queue.async {
                let realm = try! Realm()
                let podcasts = Array(realm.objects(PodcastObject.self)).map { Podcast.make(by: $0) }
                observer(.success(podcasts))
            }
            return Disposables.create()
        })
    }

    public func add(_ podcast: Podcast) -> Completable {
        return Completable.create(subscribe: { observer in
            self.queue.async {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(podcast.asManagedObject())
                    observer(.completed)
                }
            }
            return Disposables.create()
        })
    }

    public func update(_ podcast: Podcast) -> Completable {
        return Completable.create(subscribe: { obserber in
            self.queue.async {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(podcast.asManagedObject())
                    obserber(.completed)
                }
            }
            return Disposables.create()
        })
    }

    public func remove(_ podcast: Podcast) -> Completable {
        return Completable.create(subscribe: { observer in
            self.queue.async {
                let realm = try! Realm()
                try! realm.write {
                    guard let target = realm.object(ofType: PodcastObject.self, forPrimaryKey: podcast.feedUrl.absoluteString) else {
                        observer(.completed)
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

                    observer(.completed)
                }
            }
            return Disposables.create()
        })
    }
}
