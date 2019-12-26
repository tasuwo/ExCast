//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation
import RxSwift

public class PodcastGateway: PodcastGatewayProtocol {
    private let session: URLSession
    private let factory: PodcastFactoryProtocol.Type

    public init(session: URLSession, factory: PodcastFactoryProtocol.Type) {
        self.session = session
        self.factory = factory
    }

    public func fetch(feed: URL) -> Observable<Podcast> {
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

                guard let podcast = self.factory.make(by: xml) else {
                    // TODO: Error handling
                    observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                    return
                }

                observer.onNext(podcast)
                observer.onCompleted()
            }

            task.resume()

            return Disposables.create { task.cancel() }
        }
    }
}
