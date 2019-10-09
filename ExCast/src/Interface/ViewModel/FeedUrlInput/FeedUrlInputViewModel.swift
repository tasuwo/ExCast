//
//  FeedUrlInputViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

protocol FeedUrlInputViewProtocol: AnyObject {
    func showMessage(_ message: String)
    func didFetchPodcastSuccessfully()
}

class FeedUrlInputViewModel {
    private let service: PodcastServiceProtocol
    private let gateway: PodcastGatewayProtocol

    weak var view: FeedUrlInputViewProtocol?

    private let disposeBag = DisposeBag()

    var url = BehaviorRelay<String>(value: "")
    var isValid: Observable<Bool> {
        return url.map { url in
            !url.isEmpty
        }
    }

    private var feedUrlDisposable: Disposable!

    // MARK: - Initializer

    init(service: PodcastServiceProtocol, gateway: PodcastGatewayProtocol) {
        self.service = service
        self.gateway = gateway
    }

    // MARK: - Methods

    func fetchPodcast() {
        guard let url = URL(string: self.url.value) else {
            view?.showMessage(NSLocalizedString("FeedUrlInputView.error.failedToFindPodcast", comment: ""))
            return
        }

        gateway.fetch(feed: url).subscribe { [self] event in
            switch event {
            case .error:
                self.view?.showMessage(NSLocalizedString("FeedUrlInputView.error.failedToFindPodcast", comment: ""))
            case let .next(podcast):
                self.view?.showMessage(String(format: NSLocalizedString("FeedUrlInputView.success.fetchPodcast", comment: ""), podcast.show.title))
                self.store(podcast)
                self.view?.didFetchPodcastSuccessfully()
            case .completed: break
            }
        }.disposed(by: disposeBag)
    }

    private func store(_ podcast: Podcast) {
        DispatchQueue.global().async {
            self.service.command.accept(.create(podcast))
        }
    }
}
