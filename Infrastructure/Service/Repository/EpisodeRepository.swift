//
//  EpisodeRepository.swift
//  Infrastructure
//
//  Created by Tasuku Tozawa on 2019/12/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RealmSwift
import RxSwift

/// @mockable
public protocol EpisodeRepositoryProtocol {
    func getAll(_ feedUrl: URL) -> Single<[Episode]>
    func update(_ id: Episode.Identity, playback: Playback?) -> Completable
    func update(_ episode: Episode) -> Completable
}

public struct EpisodeRepository: EpisodeRepositoryProtocol {
    private let queue: DispatchQueue

    // MARK: - Lifecycle

    public init(queue: DispatchQueue = DispatchQueue(label: "net.tasuwo.ExCast.Infrastructure.EpisodeRepository")) {
        self.queue = queue
    }

    // MARK: - EpisodeRepositoryProtocol

    public func getAll(_ feedUrl: URL) -> Single<[Episode]> {
        Single.create { observer in
            self.queue.async {
                // swiftlint:disable:next force_try
                let realm = try! Realm()
                guard let podcast = realm.object(ofType: PodcastObject.self, forPrimaryKey: feedUrl.absoluteString) else {
                    observer(.success([]))
                    return
                }
                observer(.success(Array(podcast.episodes).map { Episode.make(by: $0) }))
            }
            return Disposables.create()
        }
    }

    public func update(_ id: Episode.Identity, playback: Playback?) -> Completable {
        Completable.create { observer in
            self.queue.async {
                // swiftlint:disable:next force_try
                let realm = try! Realm()

                guard let target = realm.object(ofType: EpisodeObject.self, forPrimaryKey: id) else {
                    // TODO:
                    observer(.completed)
                    return
                }

                // swiftlint:disable:next force_try
                try! realm.write {
                    target.playback = playback?.asManagedObject()
                    realm.add(target, update: .modified)

                    observer(.completed)
                }
            }
            return Disposables.create()
        }
    }

    public func update(_ episode: Episode) -> Completable {
        Completable.create { observer in
            self.queue.async {
                // swiftlint:disable:next force_try
                let realm = try! Realm()

                guard let target = realm.object(ofType: EpisodeObject.self, forPrimaryKey: episode.id) else {
                    // TODO:
                    observer(.completed)
                    return
                }

                // swiftlint:disable:next force_try
                try! realm.write {
                    target.meta = episode.meta.asManagedObject()
                    target.playback = episode.playback?.asManagedObject()
                    realm.add(target, update: .modified)

                    observer(.completed)
                }
            }
            return Disposables.create()
        }
    }
}
