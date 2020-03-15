//
//  PodcastService.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxRelay
import RxSwift

public struct PodcastService: PodcastServiceProtocol {
    // MARK: - PodcastServiceProtocol

    public var state: BehaviorRelay<PodcastServiceQuery> = BehaviorRelay(value: .notLoaded)
    public var command: PublishRelay<PodcastServiceCommand> = PublishRelay()

    // MARK: - Privates

    private let repository: PodcastRepositoryProtocol
    private let gateway: PodcastGatewayProtocol

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    public init(repository: PodcastRepositoryProtocol, gateway: PodcastGatewayProtocol) {
        self.repository = repository
        self.gateway = gateway

        // MARK: Refresh

        let refreshState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isRefresh }
            .map { _ in PodcastServiceQuery.progress }

        let refreshResultState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isRefresh }
            .flatMapLatest { [self] command -> Single<[Podcast]> in
                switch command {
                case .refresh:
                    return self.repository.getAll()

                default:
                    return Single.never()
                }
            }
            .map { result -> PodcastServiceQuery in .content(result) }

        Observable
            .merge(refreshState, refreshResultState)
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
            .filter { $0.isFetch }
            .map { _ in PodcastServiceQuery.progress }

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
            .map { [self] fetchedPodcast in self.repository.update(fetchedPodcast) }
            .flatMap { [self] _ -> Single<[Podcast]> in
                self.repository.getAll()
            }
            .map { result -> PodcastServiceQuery in .content(result) }

        fetchCommand
            .bind(to: self.gateway.command)
            .disposed(by: self.disposeBag)

        Observable
            .merge(fetchState, fetchResultState)
            .bind(to: state)
            .disposed(by: disposeBag)

        // MARK: Create, Delete

        let createResultCommand = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isCreate }
            .flatMap { [self] command -> Observable<Void> in
                switch command {
                case let .create(podcast):
                    return self.repository.add(podcast).andThen(.just(Void()))

                default:
                    return .just(Void())
                }
            }
            .flatMap { _ -> Single<PodcastServiceCommand> in
                Single.just(PodcastServiceCommand.refresh)
            }

        let deleteResultCommand = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isDelete }
            .flatMap { [self] command -> Observable<Void> in
                switch command {
                case let .delete(podcast):
                    return self.repository.remove(podcast).andThen(.just(Void()))

                default:
                    return .just(Void())
                }
            }
            .flatMap { _ -> Single<PodcastServiceCommand> in
                Single.just(PodcastServiceCommand.refresh)
            }

        Observable
            .merge(createResultCommand, deleteResultCommand)
            .bind(to: command)
            .disposed(by: disposeBag)
    }
}

private extension PodcastServiceCommand {
    var isRefresh: Bool {
        if case .refresh = self { return true } else { return false }
    }

    var isFetch: Bool {
        if case .fetch = self { return true } else { return false }
    }

    var isCreate: Bool {
        if case .create = self { return true } else { return false }
    }

    var isDelete: Bool {
        if case .delete = self { return true } else { return false }
    }
}
