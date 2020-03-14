//
//  PodcastFactory.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/07.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Foundation

/// @mockable
public protocol PodcastFactoryProtocol {
    static func make(by data: Data) -> Podcast?
}

public struct PodcastFactory: PodcastFactoryProtocol {
    public static func make(by data: Data) -> Podcast? {
        let parser = XML()

        guard case let .success(node) = parser.parse(data) else {
            return nil
        }

        guard let showNode = node |> "channel", let show = Show(node: showNode) else {
            errorLog("Failed to initialize Show.")
            return nil
        }
        guard let episodeNodes = (node |> "channel" ||> "item") else {
            errorLog("Failed to initialize Item. No `channel`, `item` element.")
            return nil
        }
        let episodes = episodeNodes
            .compactMap { itemNode -> Item? in
                guard let item = Item(node: itemNode) else {
                    errorLog("Failed to initialize Item.")
                    return nil
                }
                return item
            }
            .map { item in Episode(id: item.guid, meta: item, playback: .defaultValue()) }

        return Podcast(feedUrl: show.feedUrl, meta: show, episodes: episodes)
    }
}
