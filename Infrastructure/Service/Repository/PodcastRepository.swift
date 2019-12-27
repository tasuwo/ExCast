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
    private let queue: DispatchQueue

    public init(queue: DispatchQueue = DispatchQueue(label: "net.tasuwo.ExCast.Infrastructure.PodcastRepository")) {
        self.queue = queue
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

                guard realm.object(ofType: PodcastObject.self, forPrimaryKey: podcast.feedUrl.absoluteString) == nil else {
                    // TODO:
                    observer(.completed)
                    return
                }

                try! realm.write {
                    realm.add(podcast.asManagedObject())
                    observer(.completed)
                }
            }
            return Disposables.create()
        })
    }

    public func update(_ podcast: Podcast) -> Completable {
        return Completable.create(subscribe: { observer in
            self.queue.async {
                let realm = try! Realm()

                guard let _ = realm.object(ofType: PodcastObject.self, forPrimaryKey: podcast.feedUrl.absoluteString) else {
                    // TODO:
                    observer(.completed)
                    return
                }

                try! realm.write {
                    realm.add(podcast.asManagedObject(), update: .modified)
                    observer(.completed)
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

                    if let meta = target.meta {
                        if let owner = meta.owner {
                            realm.delete(owner)
                        }
                        realm.delete(meta)
                    }

                    for episode in target.episodes {
                        if let meta = episode.meta {
                            if let enclosure = meta.enclosure {
                                realm.delete(enclosure)
                            }
                            realm.delete(meta)
                        }
                        if let playback = episode.playback {
                            realm.delete(playback)
                        }
                        realm.delete(episode)
                    }

                    realm.delete(target)

                    observer(.completed)
                }
            }
            return Disposables.create()
        })
    }
}
