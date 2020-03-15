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
    // MARK: - EpisodeServiceProtocol

    public var state: BehaviorRelay<EpisodeServiceQuery> = BehaviorRelay(value: .notLoaded)
    public var command: PublishRelay<EpisodeServiceCommand> = PublishRelay()

    // MARK: - Privates

    private let refreshedState: PublishRelay<EpisodeServiceQuery> = .init()

    private let podcastRepository: PodcastRepositoryProtocol
    private let episodeRepository: EpisodeRepositoryProtocol
    private let gateway: PodcastGatewayProtocol

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    public init(podcastRepository: PodcastRepositoryProtocol,
                episodeRepository: EpisodeRepositoryProtocol,
                gateway: PodcastGatewayProtocol) {
        self.podcastRepository = podcastRepository
        self.episodeRepository = episodeRepository
        self.gateway = gateway

        // MARK: Refresh

        let refreshState = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isRefresh }
            .map { _ in EpisodeServiceQuery.progress }

        self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isRefresh }
            .compactMap { command -> Podcast.Identity? in
                guard case let .refresh(id) = command else { return nil }
                return id
            }
            .concatMap { [unowned self] id in self.episodeRepository.getAll(id).map { (id, $0) } }
            .subscribe { event in
                switch event {
                case let .next((id, episodes)):
                    self.refreshedState.accept(.content(id, episodes))
                case .error:
                    self.refreshedState.accept(.error)
                default:
                    break
                }
            }
            .disposed(by: self.disposeBag)

        Observable
            .merge(refreshState, self.refreshedState.asObservable())
            .bind(to: state)
            .disposed(by: disposeBag)

        // MARK: Fetch

        let fetchState = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isFetch }
            .map { _ in EpisodeServiceQuery.progress }

        let fetchedState = self.gateway.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> Podcast? in
                guard case let .content(.some(podcast)) = query else { return nil }
                return podcast
            }
            .concatMap { [unowned self] podcast -> Single<Podcast.Identity> in
                self.podcastRepository.updateEpisodesMeta(podcast).andThen(.just(podcast.identity))
            }
            .concatMap { [unowned self] feedUrl -> Single<(Podcast.Identity, [Episode])> in
                return self.episodeRepository.getAll(feedUrl).map { (feedUrl, $0) }
            }
            .map { (id, episodes) -> EpisodeServiceQuery in .content(id, episodes) }

        self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { command -> PodcastGatewayCommand? in
                switch command {
                case let .fetch(feedUrl):
                    return .fetch(feedUrl)
                default:
                    return nil
                }
            }
            .bind(to: self.gateway.command)
            .disposed(by: self.disposeBag)

        Observable
            .merge(fetchState, fetchedState)
            .bind(to: state)
            .disposed(by: disposeBag)

        // MARK: Update

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

        updateResultCommand
            .subscribe()
            .disposed(by: self.disposeBag)

        // MARK: Clear

        let clearResultState = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .clear = $0 { return true } else { return false } }
            .map { _ in EpisodeServiceQuery.notLoaded }

        clearResultState
            .bind(to: state)
            .disposed(by: disposeBag)
    }
}

private extension EpisodeServiceCommand {
    var isRefresh: Bool {
        if case .refresh = self { return true } else { return false }
    }

    var isFetch: Bool {
        if case .fetch = self { return true } else { return false }
    }
}
