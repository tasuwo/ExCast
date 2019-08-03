//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

protocol PodcastGateway {

    func fetch(feed: URL, _ completion: @escaping (Result<Podcast, Error>) -> Void)

}

