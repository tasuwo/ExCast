//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxSwift

public protocol PodcastGatewayProtocol {
    func fetch(feed: URL) -> Observable<Podcast>
}
