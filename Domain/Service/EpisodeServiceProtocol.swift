//
//  EpisodeService.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/11/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

public enum EpisodeServiceQuery {
    case progress
    case error
    case content([Episode])
}

public enum EpisodeServiceCommand {
    case refresh(Podcast.Identity)
}

public protocol EpisodeServiceProtocol {
    var state: BehaviorRelay<EpisodeServiceQuery> { get }
    var command: PublishRelay<EpisodeServiceCommand> { get set }
}
