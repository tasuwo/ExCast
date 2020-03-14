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

        let refreshState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isRefresh }
            .map { _ in EpisodeServiceQuery.progress }

        command
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

        let fetchCommand = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { command -> PodcastGatewayCommand? in
                switch command {
                case let .fetch(feedUrl):
                    return .fetch(feedUrl)
                default:
                    return nil
                }
            }

        let fetchState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .fetch = $0 { return true } else { return false } }
            .map { _ in EpisodeServiceQuery.progress }

        let fetchResultState = self.gateway.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> Podcast? in
                switch query {
                case let .content(.some(podcast)):
                    return podcast
                default:
                    return nil
                }
            }
            .flatMap { [self] fetchedPodcast -> Observable<Podcast.Identity> in
                self.podcastRepository.updateEpisodesMeta(fetchedPodcast).andThen(.just(fetchedPodcast.identity))
            }
            .flatMapLatest { [unowned self] feedUrl -> Single<(Podcast.Identity, [Episode])> in
                return self.episodeRepository.getAll(feedUrl).map { (feedUrl, $0) }
            }
            .map { (id, episodes) -> EpisodeServiceQuery in .content(id, episodes) }

        fetchCommand
            .bind(to: self.gateway.command)
            .disposed(by: self.disposeBag)

        Observable
            .merge(fetchState, fetchResultState)
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
}
