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

public struct EpisodeService: EpisodeServiceProtocol {
    public var state: BehaviorRelay<EpisodeServiceQuery> = BehaviorRelay(value: .content([]))
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
            .flatMapLatest { [self] command -> Single<[Episode]> in
                switch command {
                case let .refresh(feedUrl):
                    return self.repository.getAll(feedUrl)
                }
            }
            .map { episodes -> EpisodeServiceQuery in .content(episodes) }

        Observable
            .merge(refreshState, refreshResultState)
            .bind(to: state)
            .disposed(by: disposeBag)
    }
}
