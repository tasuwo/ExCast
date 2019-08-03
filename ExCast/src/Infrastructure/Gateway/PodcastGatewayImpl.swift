//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class PodcastGatewayImpl: PodcastGateway {

    private let session: URLSession!
    private let factory: PodcastFactory!

    init(session: URLSession, factory: PodcastFactory) {
        self.session = session
        self.factory = factory
    }

    func fetch(feed: URL, _ completion: @escaping (Result<Podcast, Error>) -> Void) {
        let task = self.session.dataTask(with: feed) { [unowned self] (data, res, err) in
            if let error = err {
                completion(Result.failure(error))
                return
            }

            guard let response = res as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                // TODO:
                completion(Result.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            guard let xml = data else {
                // TODO: Error Handling
                completion(Result.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            switch self.factory.create(from: xml) {
            case .success(let podcast):
                completion(Result.success(podcast))
            case .failure(_):
                // TODO: Error handling
                completion(Result.failure(NSError(domain: "", code: -1, userInfo: nil)))
                break
            }
        }

        task.resume()
    }

}
