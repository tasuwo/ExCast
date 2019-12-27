//
//  Podcast.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import RxDataSources

public typealias Show = Channel

// sourcery: model
public struct Podcast: Entity {
    // sourcery: primaryKey
    public let feedUrl: URL

    /// Podcast's metadata.
    public let meta: Channel

    public var episodes: [Episode]

    // MARK: - Lifecycle

    public init(
        feedUrl: URL,
        meta: Channel,
        episodes: [Episode]
    ) {
        self.feedUrl = feedUrl
        self.meta = meta
        self.episodes = episodes
    }
}

extension Podcast: IdentifiableType {
    // MARK: - IndetifiableType

    public typealias Identity = URL

    public var identity: URL {
        return feedUrl
    }
}
