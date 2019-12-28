//
//  EpisodeService.swift
//  Infrastructure
//
//  Created by Tasuku Tozawa on 2019/12/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxRelay
import RxSwift

public class EpisodeService: EpisodeServiceProtocol {
    private var lastFetchedPodcastId: Podcast.Identity? = nil

    public var state: BehaviorRelay<EpisodeServiceQuery> = BehaviorRelay(value: .notLoaded)
    public var command: PublishRelay<EpisodeServiceCommand> = PublishRelay()

    private let repository: EpisodeRepositoryProtocol

    private let disposeBag = DisposeBag()

    public init(repository: EpisodeRepositoryProtocol) {
        self.repository = repository

        let refreshState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .refresh = $0 { return true } else { return false } }
            .map { _ in EpisodeServiceQuery.progress }

        let refreshResultState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .refresh = $0 { return true } else { return false } }
            .flatMapLatest { [unowned self] command -> Single<(Podcast.Identity, [Episode])> in
                switch command {
                case let .refresh(feedUrl):
                    self.lastFetchedPodcastId = feedUrl
                    return self.repository.getAll(feedUrl).map { (feedUrl, $0) }
                default:
                    return .never()
                }
            }
            .map { (id, episodes) -> EpisodeServiceQuery in .content(id, episodes) }

        let updateResultCommand = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .update = $0 { return true } else { return false } }
            .flatMap { [unowned self] command -> Observable<Void> in
                switch command {
                case let .update(id, playback):
                    return self.repository.update(id, playback: playback).andThen(.just(Void()))
                default:
                    return .just(Void())
                }
            }
            .flatMap { [unowned self] _ -> Single<EpisodeServiceCommand> in
                // TODO: Error handling
                .just(.refresh(self.lastFetchedPodcastId!))
            }

        let clearResultState = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .clear = $0 { return true } else { return false } }
            .map { _ in EpisodeServiceQuery.notLoaded }

        Observable
            .merge(refreshState, refreshResultState)
            .bind(to: state)
            .disposed(by: disposeBag)

        updateResultCommand
            .bind(to: self.command)
            .disposed(by: self.disposeBag)

        clearResultState
            .bind(to: state)
            .disposed(by: disposeBag)
    }
}
