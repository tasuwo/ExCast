//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import RxSwift

protocol PodcastGatewayProtocol {
    func fetch(feed: URL) -> Observable<Podcast>
}

class PodcastGateway: PodcastGatewayProtocol {
    private let session: URLSession!
    private let factory: PodcastFactory!

    init(session: URLSession, factory: PodcastFactory) {
        self.session = session
        self.factory = factory
    }

    func fetch(feed: URL) -> Observable<Podcast> {
        return Observable.create { observer in
            let task = self.session.dataTask(with: feed) { [unowned self] data, res, err in
                if let error = err {
                    observer.onError(error)
                    return
                }

                guard let response = res as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) else {
                    // TODO: Error Handling
                    observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                    return
                }

                guard let xml = data else {
                    // TODO: Error Handling
                    observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                    return
                }

                switch self.factory.create(from: xml) {
                case let .success(podcast):
                    observer.onNext(podcast)
                    observer.onCompleted()
                case .failure:
                    // TODO: Error handling
                    observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                }
            }

            task.resume()

            return Disposables.create { task.cancel() }
        }
    }
}
