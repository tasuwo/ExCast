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
    func getAll(_ feedUrl: URL) -> Observable<Result<[Episode], Error>>
    func update(_ episode: Episode) -> Observable<Result<Episode, Error>>
}

public struct EpisodeRepository: EpisodeRepositoryProtocol {
    public init() {}

    public func getAll(_ feedUrl: URL) -> Observable<Result<[Episode], Error>> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                let realm = try! Realm()
                guard let podcast = realm.object(ofType: PodcastObject.self, forPrimaryKey: feedUrl.absoluteString) else {
                    observer.onNext(.success([]))
                    observer.onCompleted()
                    return
                }

                observer.onNext(.success(Array(podcast.episodes).map { Episode.makePersistable(managedObject: $0) }))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    public func update(_ episode: Episode) -> Observable<Result<Episode, Error>> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                let realm = try! Realm()

                guard let target = realm.object(ofType: EpisodeObject.self, forPrimaryKey: episode.id) else {
                    // TODO:
                    observer.onCompleted()
                    return
                }

                try! realm.write {
                    target.meta = episode.meta.asManagedObject()
                    target.playback = episode.playback?.asManagedObject()
                    realm.add(target, update: .modified)

                    observer.onNext(.success(episode))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
