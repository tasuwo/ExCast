//
//  Item.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/11/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Foundation

// sourcery: model
/**
 * [Item](https://cyber.harvard.edu/rss/rss.html#hrelementsOfLtitemgt) element in [RSS 2.0 Specification](https://cyber.harvard.edu/rss/rss.html).
 * Recommended tags also specified in [Apple's podcast guide](k).
 */
public struct Item: Codable, Equatable {
    /// The string that uniquely identifies the episode.
    /// If a GUID is not provided in RSS feed, an enclosure URL will be used instead.
    public let guid: String

    /// If this value is false, the guid assumed to be a url.
    public let guidIsPermaLink: Bool?

    /// An episode title.
    public let title: String

    /// An episode subtitle.
    public let subTitle: String?

    /// The episode content, file size, and file type information.
    public let enclosure: Enclosure

    /// The date and time when an episode was released.
    public let pubDate: Date?

    /// An episode description.
    public let itemDescription: String?

    /// The duration of an episode.
    /// Different duration formats are accepted.
    public let duration: Double?

    /// An episode link URL.
    public let link: URL?

    /// The episode artwork.
    public let artwork: URL?

    // MARK: - Lifecycle

    public init(
        guid: String,
        guidIsPermaLink: Bool?,
        title: String,
        subTitle: String?,
        enclosure: Enclosure,
        pubDate: Date?,
        itemDescription: String?,
        duration: Double?,
        link: URL?,
        artwork: URL?
    ) {
        self.guid = guid
        self.guidIsPermaLink = guidIsPermaLink
        self.title = title
        self.subTitle = subTitle
        self.enclosure = enclosure
        self.pubDate = pubDate
        self.itemDescription = itemDescription
        self.duration = duration
        self.link = link
        self.artwork = artwork
    }
}

extension Item {
    // MARK: - Lifecycle

    public init?(node: XmlNode) {
        guard let enclosure = Enclosure(node: node) else {
            errorLog("Failed to initialize Item because of failure of initializing enclosure.")
            return nil
        }
        self.enclosure = enclosure

        guid = {
            if let guid = (node |> "guid")?.value {
                return guid
            } else {
                return enclosure.url.absoluteString
            }
        }()

        guidIsPermaLink = {
            if let isPermaLink = Bool((node |> "guid")?.attributes["isPermaLink"] ?? "") {
                return isPermaLink
            } else {
                return nil
            }
        }()

        guard let title = (node |> "title")?.value else {
            errorLog("Failed to initialize Item. No `title` element.")
            return nil
        }
        self.title = title

        subTitle = (node |> "itunes:subtitle")?.value

        pubDate = {
            if let pubDateStr = (node |> "pubDate")?.value {
                return parseRfc822DateString(pubDateStr)
            } else {
                return nil
            }
        }()

        itemDescription = (node |> "description")?.value
        duration = Self.parseDuration((node |> "itunes:duration")?.value)
        link = {
            if let link = (node |> "link")?.value {
                return URL(string: link)
            } else {
                return nil
            }
        }()

        artwork = {
            if let artwork = (node |> "itunes:image")?.value {
                return URL(string: artwork)
            } else {
                return nil
            }
        }()
    }

    // TODO: duration の表現は他にもあるので対応したい
    private static func parseDuration(_ str: String?) -> Double? {
        guard let durationStr = str else { return nil }

        // TODO: 数値変換に失敗した際の処理
        let parts = durationStr.split(separator: ":").reversed().map { Int($0) ?? 0 }

        let duration = parts.enumerated().reduce(0) { prev, val in
            prev + Double(val.element) * NSDecimalNumber(decimal: pow(60, val.offset)).doubleValue
        }
        return duration
    }
}
