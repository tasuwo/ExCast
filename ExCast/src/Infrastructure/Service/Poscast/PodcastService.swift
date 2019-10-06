//
//  PodcastService.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

struct PodcastService: Service {
    typealias Item = Podcast

    var state: BehaviorRelay<Query<Podcast>> = BehaviorRelay(value: .content([]))
    var command: PublishRelay<Command<Podcast>> = PublishRelay()

    private let repository: PodcastRepository
    private let disposeBag = DisposeBag()

    init(podcastRepository: PodcastRepository) {
        self.repository = podcastRepository

        let refreshState = command
            .filter { if case .refresh = $0 { return true } else { return false } }
            .map { _ in Query<Podcast>.progress }

        let refreshResultState = command
            .flatMapLatest({ [self] command -> Observable<Result<[Podcast], Error>> in
                switch command {
                case .refresh:
                    return self.repository.getAll()
                default:
                    return Observable.never()
                }
            })
            .map({ result -> Query<Podcast> in
                switch result {
                case let .success(podcasts):
                    return .content(podcasts)
                case .failure(_):
                    return .error
                }
            })

        let createResultCommand = command
            .flatMapLatest({ [self] command -> Observable<Result<Podcast, Error>> in
                switch command {
                case let .create(podcast):
                    return self.repository.add(podcast)
                default:
                    return Observable.never()
                }
            })
            .flatMap({ result -> Single<Command<Podcast>> in
                switch result {
                case .success(_):
                    return Single.just(Command<Podcast>.refresh)
                default:
                    return Single.never()
                }
            })

        let deleteResultCommand = command
            .flatMapLatest({ [self] command -> Observable<Result<Podcast, Error>> in
                switch command {
                case let .delete(podcast):
                    return self.repository.remove(podcast)
                default:
                    return Observable.never()
                }
            })
            .flatMap({ result -> Single<Command<Podcast>> in
                switch result {
                case .success(_):
                    return Single.just(Command<Podcast>.refresh)
                default:
                    return Single.never()
                }
            })

        Observable
            .merge(refreshState, refreshResultState)
            .bind(to: self.state)
            .disposed(by: self.disposeBag)

        Observable
            .merge(createResultCommand, deleteResultCommand)
            .bind(to: self.command)
            .disposed(by: self.disposeBag)
    }
}
