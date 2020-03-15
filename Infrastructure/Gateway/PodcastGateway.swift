//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

// TODO: リファクタして外す
// swiftlint:disable all

import Common
import Domain
import Foundation
import RxRelay
import RxSwift

public class PodcastGateway: PodcastGatewayProtocol {
    // MARK: - PodcastGatewayProtocol

    public var state: BehaviorRelay<PodcastGatewayQuery> = BehaviorRelay(value: .content(nil))
    public var command: PublishRelay<PodcastGatewayCommand> = PublishRelay()

    // MARK: - Privates

    private let fetchedState: PublishRelay<PodcastGatewayQuery> = .init()

    private let session: URLSession
    private let factory: PodcastFactoryProtocol.Type

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    public init(session: URLSession, factory: PodcastFactoryProtocol.Type) {
        self.session = session
        self.factory = factory

        // MARK: Fetch

        let fetchingState = self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .filter { $0.isFetch }
            .map { _ in PodcastGatewayQuery.progress }

        self.command
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { command -> URL? in
                guard case let .fetch(feedUrl) = command else { return nil }
                return feedUrl
            }
            .concatMap { [unowned self] url in
                self.fetch(feed: url).asObservable().materialize()
            }
            .subscribe { [unowned self] event in
                switch event {
                case let .next(.next(podcast)):
                    self.fetchedState.accept(.content(podcast))

                case .next(.error):
                    self.fetchedState.accept(.error)

                default:
                    break
                }
            }
            .disposed(by: self.disposeBag)

        Observable
            .merge(fetchingState, self.fetchedState.asObservable())
            .bind(to: self.state)
            .disposed(by: self.disposeBag)
    }

    // MARK: - Private Methods

    private func fetch(feed: URL) -> Single<Podcast> {
        Single.create { observer in
            let task = self.session.dataTask(with: feed) { [unowned self] data, res, err in
                if let error = err {
                    observer(.error(error))
                    return
                }

                guard let response = res as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) else {
                    // TODO: Error Handling
                    observer(.error(NSError(domain: "", code: -1, userInfo: nil)))
                    return
                }

                guard let xml = data else {
                    // TODO: Error Handling
                    observer(.error(NSError(domain: "", code: -1, userInfo: nil)))
                    return
                }

                guard let podcast = self.factory.make(by: xml) else {
                    // TODO: Error handling
                    observer(.error(NSError(domain: "", code: -1, userInfo: nil)))
                    return
                }

                observer(.success(podcast))
            }

            task.resume()

            return Disposables.create { task.cancel() }
        }
    }
}

private extension PodcastGatewayCommand {
    var isFetch: Bool {
        if case .fetch = self { return true } else { return false }
    }
}
