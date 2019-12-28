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
    public var state: BehaviorRelay<PodcastServiceQuery> = BehaviorRelay(value: .content([]))
    public var command: PublishRelay<PodcastServiceCommand> = PublishRelay()

    private let repository: PodcastRepositoryProtocol
    private let gateway: PodcastGatewayProtocol

    private let disposeBag = DisposeBag()

    public init(repository: PodcastRepositoryProtocol, gateway: PodcastGatewayProtocol) {
        self.repository = repository
        self.gateway = gateway

        let refreshState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .refresh = $0 { return true } else { return false } }
            .map { _ in PodcastServiceQuery.progress }

        let refreshResultState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .refresh = $0 { return true } else { return false } }
            .flatMapLatest { [self] command -> Single<[Podcast]> in
                switch command {
                case .refresh:
                    return self.repository.getAll()
                default:
                    return Single.never()
                }
            }
            .map { result -> PodcastServiceQuery in .content(result) }

        let fetchState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .fetch = $0 { return true } else { return false } }
            .map { _ in PodcastServiceQuery.progress }

        let fetchResultState = command
            .filter { if case .fetch = $0 { return true } else { return false } }
            .flatMapLatest { [self] command -> Observable<Podcast> in
                switch command {
                case let .fetch(url):
                    return self.gateway.fetch(feed: url)
                default:
                    return Observable.never()
                }
            }
            .map { [self] fetchedPodcast in self.repository.update(fetchedPodcast) }
            .flatMap { [self] _ -> Single<[Podcast]> in
                self.repository.getAll()
            }
            .map { result -> PodcastServiceQuery in .content(result) }

        let createResultCommand = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .create = $0 { return true } else { return false } }
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
            .filter { if case .delete = $0 { return true } else { return false } }
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
            .merge(refreshState, refreshResultState)
            .bind(to: state)
            .disposed(by: disposeBag)

        Observable
            .merge(fetchState, fetchResultState)
            .bind(to: state)
            .disposed(by: disposeBag)

        Observable
            .merge(createResultCommand, deleteResultCommand)
            .bind(to: command)
            .disposed(by: disposeBag)
    }
}
