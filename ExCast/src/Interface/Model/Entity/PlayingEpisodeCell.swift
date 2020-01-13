//
//  PlayingEpisodeCell.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2020/01/08.
//  Copyright © 2020 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxDataSources

struct PlayingEpisodeCell: Equatable {
    let id: Episode.Identity
    let indexPath: IndexPath
    let currentPlaybackSec: Double?
}

extension PlayingEpisodeCell: IdentifiableType {
    // MARK: - IndetifiableType

    public typealias Identity = Episode.Identity

    public var identity: String {
        return self.id
    }
}
