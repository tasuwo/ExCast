//
//  PodcastGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

public enum PodcastGatewayQuery: Equatable {
    case content(Podcast?)
    case progress
    case error
}

public enum PodcastGatewayCommand: Equatable {
    case fetch(URL)
}

/// @mockable
public protocol PodcastGatewayProtocol {
    var state: BehaviorRelay<PodcastGatewayQuery> { get }
    var command: PublishRelay<PodcastGatewayCommand> { get }
}
