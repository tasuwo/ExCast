//
//  EpisodeService.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/11/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

public enum EpisodeServiceQuery: Equatable {
    case notLoaded
    case progress
    case error
    case content(Podcast.Identity, [Episode])
    case clear
}

public enum EpisodeServiceCommand {
    case clear
    case refresh(Podcast.Identity)
    case fetch(Podcast.Identity)
    case update(Episode.Identity, Playback?)
}

/// @mockable
public protocol EpisodeServiceProtocol {
    var state: BehaviorRelay<EpisodeServiceQuery> { get }
    var command: PublishRelay<EpisodeServiceCommand> { get set }
}
