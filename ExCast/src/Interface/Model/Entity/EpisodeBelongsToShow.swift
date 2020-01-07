//
//  EpisodeBelongsToShow.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import Domain

struct EpisodeBelongsToShow {
    let id: Podcast.Identity
    let episode: Episode
    let show: Show
}
