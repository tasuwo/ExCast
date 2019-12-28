//
//  ListingEpisode.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxDataSources

struct ListingEpisode: Equatable {
    let episode: Episode
    let isPlaying: Bool

    func startedPlay() -> ListingEpisode {
        return .init(episode: self.episode, isPlaying: true)
    }

    func finishedPlay() -> ListingEpisode {
        return .init(episode: self.episode, isPlaying: false)
    }
}

extension ListingEpisode: IdentifiableType {
    // MARK: - IndetifiableTyp

    typealias Identity = Episode.Identity

    var identity: String {
        return episode.identity
    }
}
