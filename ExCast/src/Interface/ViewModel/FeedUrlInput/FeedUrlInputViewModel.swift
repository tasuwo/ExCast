//
//  FeedUrlInputViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxSwift
import RxRelay

class FeedUrlInputViewModel {
    
    private let service: PodcastService!
    private let gateway: PodcastGateway!

    var url = BehaviorRelay<String>(value: "")
    var isValid: Observable<Bool> {
        return self.url.map { url in
            return url.count > 0
        }
    }

    private var feedUrlDisposable: Disposable!

    // MARK: - Initializer
    
    init(service: PodcastService, gateway: PodcastGateway) {
        self.service = service
        self.gateway = gateway
    }
    
    // MARK: - Methods
    
    func fetchPodcast(_ completion: @escaping ((Podcast?) -> Void)) {
        guard let url = URL(string: self.url.value) else {
            completion(nil)
            return
        }

        self.gateway.fetch(feed: url) { result in
            switch result {
            case .success(let podcast):
                completion(podcast)
            case .failure(_):
                // TODO: Error handling
                completion(nil)
            }
        }
    }

    func store(_ podcast: Podcast) {
        self.service.command.accept(.create(podcast))
    }
}
