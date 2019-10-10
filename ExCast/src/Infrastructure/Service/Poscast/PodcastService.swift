//
//  PodcastService.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

struct PodcastService: PodcastServiceProtocol {
    var state: BehaviorRelay<PodcastServiceQuery> = BehaviorRelay(value: .content([]))
    var command: PublishRelay<PodcastServiceCommand> = PublishRelay()

    private let repository: PodcastRepositoryProtocol
    private let gateway: PodcastGatewayProtocol

    private let disposeBag = DisposeBag()

    init(repository: PodcastRepositoryProtocol, gateway: PodcastGatewayProtocol) {
        self.repository = repository
        self.gateway = gateway

        let refreshState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .refresh = $0 { return true } else { return false } }
            .map { _ in PodcastServiceQuery.progress }

        let refreshResultState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .flatMapLatest { [self] command -> Observable<Result<[Podcast], Error>> in
                switch command {
                case .refresh:
                    return self.repository.getAll()
                default:
                    return Observable.never()
                }
            }
            .map { result -> PodcastServiceQuery in
                switch result {
                case let .success(podcasts):
                    return .content(podcasts)
                case .failure:
                    return .error
                }
            }

        let fetchState = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { if case .fetch(_) = $0 { return true } else { return false } }
            .map { _ in PodcastServiceQuery.progress }

        let fetchResultState = command
            .flatMapLatest { [self] command -> Observable<Podcast> in
                switch command {
                case let .fetch(url):
                    return self.gateway.fetch(feed: url)
                default:
                    return Observable.never()
                }
            }
            .flatMap { [self] i in self.repository.update(i) }
            .flatMap { [self] result -> Observable<Result<[Podcast], Error>> in
                switch result {
                case .success:
                    return self.repository.getAll()
                default:
                    return Observable.never()
                }
            }
            .map { result -> PodcastServiceQuery in
                switch result {
                case let .success(podcasts):
                    return .content(podcasts)
                case .failure:
                    return .error
                }
            }

        let createResultCommand = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .flatMapLatest { [self] command -> Observable<Result<Podcast, Error>> in
                switch command {
                case let .create(podcast):
                    return self.repository.add(podcast)
                default:
                    return Observable.never()
                }
            }
            .flatMap { result -> Single<PodcastServiceCommand> in
                switch result {
                case .success:
                    return Single.just(PodcastServiceCommand.refresh)
                default:
                    return Single.never()
                }
            }

        let deleteResultCommand = command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .flatMapLatest { [self] command -> Observable<Result<Podcast, Error>> in
                switch command {
                case let .delete(podcast):
                    return self.repository.remove(podcast)
                default:
                    return Observable.never()
                }
            }
            .flatMap { result -> Single<PodcastServiceCommand> in
                switch result {
                case .success:
                    return Single.just(PodcastServiceCommand.refresh)
                default:
                    return Single.never()
                }
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
