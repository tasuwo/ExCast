//
//  PlayerConfiguration.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

struct PlayerConfiguration {
    let forwardSkipTime: TimeInterval
    let backwardSkipTime: TimeInterval

    static let `default` = PlayerConfiguration(forwardSkipTime: 15, backwardSkipTime: 15)
}
