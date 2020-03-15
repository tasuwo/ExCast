//
//  FeedUrlInputViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxCocoa
import RxRelay
import RxSwift

protocol FeedUrlInputViewProtocol: AnyObject {
    func showMessage(_ message: String)
    func didFetchPodcastSuccessfully()
}

protocol FeedUrlInputViewModelType {
    var inputs: FeedUrlInputViewModelInputs { get }
    var outputs: FeedUrlInputViewModelOutputs { get }
}

protocol FeedUrlInputViewModelInputs {
    var feedUrl: BehaviorRelay<String> { get }

    var podcastFetched: PublishRelay<Void> { get }
}

protocol FeedUrlInputViewModelOutputs {
    var isFeedUrlValid: Driver<Bool> { get }

    var messageDisplayed: Signal<String> { get }
}

class FeedUrlInputViewModel: FeedUrlInputViewModelType, FeedUrlInputViewModelInputs, FeedUrlInputViewModelOutputs {
    // MARK: - FeedUrlInputViewModelType

    var inputs: FeedUrlInputViewModelInputs { self }
    var outputs: FeedUrlInputViewModelOutputs { self }

    // MARK: - FeedUrlInputViewModelInputs

    var feedUrl: BehaviorRelay<String>
    var podcastFetched: PublishRelay<Void>

    // MARK: - FeedUrlInputViewModelOutputs

    var isFeedUrlValid: Driver<Bool>
    var messageDisplayed: Signal<String>

    // MARK: - Privates

    private let _messageDisplayed: PublishRelay<String> = .init()

    private let service: PodcastServiceProtocol
    private let gateway: PodcastGatewayProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(service: PodcastServiceProtocol, gateway: PodcastGatewayProtocol) {
        // MARK: Privates

        self.service = service
        self.gateway = gateway

        // MARK: Inputs

        self.feedUrl = .init(value: "")
        self.podcastFetched = .init()

        // MARK: Outputs

        self.isFeedUrlValid = self.feedUrl
            .map { $0.isEmpty == false }
            .asDriver(onErrorDriveWith: .empty())

        self.messageDisplayed = self._messageDisplayed
            .asSignal(onErrorSignalWith: .empty())

        // MARK: Binding

        self.podcastFetched
            .compactMap { [weak self] _ -> URL? in
                URL(string: self?.feedUrl.value ?? "")
            }
            .map { url -> PodcastGatewayCommand in .fetch(url) }
            .bind(to: self.gateway.command)
            .disposed(by: self.disposeBag)

        self.gateway.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> PodcastServiceCommand? in
                guard case let .content(.some(podcast)) = query else { return nil }
                return .create(podcast)
            }
            .bind(to: self.service.command)
            .disposed(by: self.disposeBag)

        let fetchResultMessage = self.gateway.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> String? in
                switch query {
                case let .content(.some(podcast)):
                    return String(format: NSLocalizedString("FeedUrlInputView.success.fetchPodcast", comment: ""), podcast.meta.title)

                case .error:
                    return NSLocalizedString("FeedUrlInputView.error.failedToFindPodcast", comment: "")

                default:
                    return nil
                }
            }

        let invalidUrlMessage = self.podcastFetched
            .compactMap { [weak self] _ -> String? in
                guard URL(string: self?.feedUrl.value ?? "") != nil else {
                    return NSLocalizedString("FeedUrlInputView.error.failedToFindPodcast", comment: "")
                }
                return nil
            }

        Observable
            .merge(fetchResultMessage, invalidUrlMessage)
            .bind(to: self._messageDisplayed)
            .disposed(by: self.disposeBag)
    }
}
