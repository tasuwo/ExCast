//
//  FeedUrlInputViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class FeedUrlInputViewModel {
    
    private let repository: PodcastRepository!
    private let gateway: PodcastGateway!

    var url: Dynamic<String>
    private var feedUrlBond: Bond<String>!
    var isValid: Dynamic<Bool>

    // MARK: - Initializer
    
    init(repository: PodcastRepository, gateway: PodcastGateway) {
        self.repository = repository
        self.gateway = gateway

        self.url = Dynamic("")
        self.isValid = Dynamic(false)
    }
    
    // MARK: - Methods
    
    func setup() {
        // 初回の View への同期、もっと綺麗な方法はないか
        self.url.value = ""
        self.isValid.value = false

        self.feedUrlBond = Bond() { (name: String) in
            self.isValid.value = self.evaluateValidity()
        }
        self.feedUrlBond.bind(self.url)
    }

    func evaluateValidity() -> Bool {
        return self.url.value.count != 0
    }

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
        try! self.repository.add(podcast)
    }
}
