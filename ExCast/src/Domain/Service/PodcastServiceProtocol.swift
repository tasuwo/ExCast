//
//  Command.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

enum PodcastServiceQuery {
    case progress
    case error
    case content([Podcast])
}

enum PodcastServiceCommand {
    case refresh
    case create(Podcast)
    case delete(Podcast)
}

protocol PodcastServiceProtocol {
    var state: BehaviorRelay<PodcastServiceQuery> { get }
    var command: PublishRelay<PodcastServiceCommand> { get set }
}
