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
    public var state: BehaviorRelay<EpisodeServiceQuery> = BehaviorRelay(value: .notLoaded)
    public var command: PublishRelay<EpisodeServiceCommand> = PublishRelay()

    private let podcastRepository: PodcastRepositoryProtocol
    private let episodeRepository: EpisodeRepositoryProtocol
    private let gateway: PodcastGatewayProtocol

    private let disposeBag = DisposeBag()

    public init(podcastRepository: PodcastRepositoryProtocol, episodeRepository: EpisodeRepositoryProtocol, gateway: PodcastGatewayProtocol) {
        self.podcastRepository = podcastRepository
        self.episodeRepository = episodeRepository
        self.gateway = gateway

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
                    return self.episodeRepository.getAll(feedUrl).map { (feedUrl, $0) }
                default:
                    return .never()
                }
            }
            .map { (id, episodes) -> EpisodeServiceQuery in .content(id, episodes) }

        let fetchState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .fetch = $0 { return true } else { return false } }
            .map { _ in EpisodeServiceQuery.progress }

        let fetchResultState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .fetch = $0 { return true } else { return false } }
            .flatMapLatest { [self] command -> Observable<Podcast> in
                switch command {
                case let .fetch(feedUrl):
                    return self.gateway.fetch(feed: feedUrl)
                default:
                    return Observable.never()
                }
            }
            .flatMap { [self] fetchedPodcast -> Observable<Podcast.Identity> in
                self.podcastRepository.updateEpisodesMeta(fetchedPodcast).andThen(.just(fetchedPodcast.identity))
            }
            .flatMapLatest { [unowned self] feedUrl -> Single<(Podcast.Identity, [Episode])> in
                return self.episodeRepository.getAll(feedUrl).map { (feedUrl, $0) }
            }
            .map { (id, episodes) -> EpisodeServiceQuery in .content(id, episodes) }

        let updateResultCommand = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .update = $0 { return true } else { return false } }
            .flatMap { [unowned self] command -> Observable<Void> in
                switch command {
                case let .update(id, playback):
                    return self.episodeRepository.update(id, playback: playback).andThen(.just(Void()))
                default:
                    return .just(Void())
                }
            }

        let clearResultState = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .clear = $0 { return true } else { return false } }
            .map { _ in EpisodeServiceQuery.notLoaded }

        Observable
            .merge(refreshState, refreshResultState)
            .bind(to: state)
            .disposed(by: disposeBag)

        Observable
            .merge(fetchState, fetchResultState)
            .bind(to: state)
            .disposed(by: disposeBag)

        updateResultCommand
            .subscribe()
            .disposed(by: self.disposeBag)

        clearResultState
            .bind(to: state)
            .disposed(by: disposeBag)
    }
}
