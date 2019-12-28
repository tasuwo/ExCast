//
//  PlayerConfiguration.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

// sourcery: model
public struct PlayerConfiguration {
    public let forwardSkipTime: TimeInterval
    public let backwardSkipTime: TimeInterval

    public static let `default` = PlayerConfiguration(forwardSkipTime: 15, backwardSkipTime: 15)

    // MARK: - Lifecycle

    public init(
        forwardSkipTime: TimeInterval,
        backwardSkipTime: TimeInterval
    ) {
        self.forwardSkipTime = forwardSkipTime
        self.backwardSkipTime = backwardSkipTime
    }
}
