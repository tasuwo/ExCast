//
//  Episode.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/11/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import RxDataSources

// sourcery: model
public struct Episode: Entity {
    // sourcery: primaryKey
    public let id: String
    /// メタ情報
    public let meta: Item
    /// 再生情報. 未再生の場合は nil
    public let playback: Playback?

    // MARK: - Lifecycle

    public init(
        id: String,
        meta: Item,
        playback: Playback?
    ) {
        self.id = id
        self.meta = meta
        self.playback = playback
    }
}

extension Episode: IdentifiableType {
    // MARK: - IndetifiableType

    public typealias Identity = String

    public var identity: String {
        return id
    }
}
