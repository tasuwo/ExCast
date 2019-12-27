//
//  Channel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/11/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

// sourcery: model
/**
 * [Channel](https://cyber.harvard.edu/rss/rss.html#requiredChannelElements) element in [RSS 2.0 Specification](https://cyber.harvard.edu/rss/rss.html).
 * Recommended tags also specified in [Apple's podcast guide](https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
 */
public struct Channel: Codable, Equatable {
    public let feedUrl: URL

    /// The show title.
    public let title: String

    /// The show description.
    public let showDescription: String

    /// The artwork for the show.
    public let artwork: URL

    /// The show category information. For a complete list of categories and subcategories, see [Apple Podcasts categories](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12).
    public let categories: [String]

    /// The podcast parental advisory information.
    public let explicit: Bool

    /// The language spoken on the show.
    public let language: Language

    /// The group responsible for creating the show.
    public let author: String?

    /// The website associated with a podcast.
    public let site: URL?

    /// The podcast owner contact information.
    public let owner: ChannelOwner?

    // MARK: - Lifecycle

    public init(
        feedUrl: URL,
        title: String,
        showDescription: String,
        artwork: URL,
        categories: [String],
        explicit: Bool,
        language: Language,
        author: String?,
        site: URL?,
        owner: ChannelOwner?
    ) {
        self.feedUrl = feedUrl
        self.title = title
        self.showDescription = showDescription
        self.artwork = artwork
        self.categories = categories
        self.explicit = explicit
        self.language = language
        self.author = author
        self.site = site
        self.owner = owner
    }
}

extension Channel {
    // MARK: - Lifecycle

    public init?(node: XmlNode) {
        guard let feedUrlCandidates = node ||> "atom:link" else {
            return nil
        }
        let feedUrlNode = feedUrlCandidates.first { $0.attributes["rel"] == "self" }

        guard let feedUrlStr = feedUrlNode?.attributes["href"],
            let feedUrl = URL(string: feedUrlStr) else {
            return nil
        }
        self.feedUrl = feedUrl

        guard let title = (node |> "title")?.value else {
            return nil
        }
        self.title = title

        guard let description = (node |> "description")?.value else {
            return nil
        }
        showDescription = description

        guard let artworkUrlStr = (node |> "itunes:image")?.attributes["href"],
            let artwork = URL(string: artworkUrlStr) else {
            return nil
        }
        self.artwork = artwork

        // TODO: categories
        categories = []

        guard let explicitStr = (node |> "itunes:explicit")?.value else {
            return nil
        }
        explicit = explicitStr == "yes" ? true : false

        guard let languageStr = (node |> "language")?.value,
            let language = Language(languageStr) else {
            return nil
        }
        self.language = language

        author = (node |> "itunes:author")?.value

        site = {
            if let link = (node |> "link")?.value {
                return URL(string: link)
            } else {
                return nil
            }
        }()

        owner = ChannelOwner(node: node)
    }
}
