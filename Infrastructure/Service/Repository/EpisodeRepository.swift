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

public protocol EpisodeRepositoryProtocol {
    func getAll(_ feedUrl: URL) -> Single<[Episode]>
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
        return Single.create { observer in
            self.queue.async {
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

    public func update(_ episode: Episode) -> Completable {
        return Completable.create { observer in
            self.queue.async {
                let realm = try! Realm()

                guard let target = realm.object(ofType: EpisodeObject.self, forPrimaryKey: episode.id) else {
                    // TODO:
                    observer(.completed)
                    return
                }

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
