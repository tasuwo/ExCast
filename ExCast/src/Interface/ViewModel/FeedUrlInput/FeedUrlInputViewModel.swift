//
//  FeedUrlInputViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxSwift

class FeedUrlInputViewModel {
    
    private let repository: PodcastRepository!
    private let gateway: PodcastGateway!

    var url = BehaviorSubject<String>(value: "")
    var isValid: Observable<Bool> {
        return self.url.map { url in
            return url.count > 0
        }
    }

    private var feedUrlDisposable: Disposable!

    // MARK: - Initializer
    
    init(repository: PodcastRepository, gateway: PodcastGateway) {
        self.repository = repository
        self.gateway = gateway
    }
    
    // MARK: - Methods
    
    func fetchPodcast(_ completion: @escaping ((Podcast?) -> Void)) {
        guard let url = URL(string: try! self.url.value()) else {
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
        try! self.repository.add(podcast)
    }
}
