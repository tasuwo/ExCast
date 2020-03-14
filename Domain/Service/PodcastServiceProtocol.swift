//
//  Command.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

public enum PodcastServiceQuery {
    case notLoaded
    case progress
    case error
    case content([Podcast])
}

public enum PodcastServiceCommand {
    case refresh
    case fetch(URL)
    case create(Podcast)
    case delete(Podcast)
}

/// @mockable
public protocol PodcastServiceProtocol {
    var state: BehaviorRelay<PodcastServiceQuery> { get }
    var command: PublishRelay<PodcastServiceCommand> { get set }
}
