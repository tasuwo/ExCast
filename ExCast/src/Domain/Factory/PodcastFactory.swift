//
//  PodcastFactory.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class PodcastFactory: NSObject {
    // MARK: - Methods

    func create(from data: Data) -> Result<Podcast, Error> {
        let parser = XML()
        switch parser.parse(data) {
        case let .success(node):
            guard let show = composeShow(by: node |> "channel") else {
                return Result.failure(NSError(domain: "", code: -1, userInfo: nil))
            }

            let episodes = (node |> "channel" ||> "item")?.compactMap { [weak self] item in
                self?.composeItem(by: item)
            }

            return Result.success(Podcast(show: show, episodes: episodes ?? []))
        case let .failure(err):
            return Result.failure(err)
        }
    }

    private func composeShow(by node: XmlNode?) -> Podcast.Show? {
        guard
            let node = node,
            let feedUrlCandidates = node ||> "atom:link",
            let title = (node |> "title")?.value,
            let description = (node |> "description")?.value,
            // media:thumbnail ???
            let artworkUrlStr = (node |> "itunes:image")?.attributes["href"],
            let artwork = URL(string: artworkUrlStr),
            let explicitStr = (node |> "itunes:explicit")?.value,
            let languageStr = (node |> "language")?.value,
            let language = Language.fromString(languageStr) else {
            return nil
        }

        let feedUrlNode = feedUrlCandidates.first { $0.attributes["rel"] == "self" }
        guard
            let feedUrlStr = feedUrlNode?.attributes["href"],
            let feedUrl = URL(string: feedUrlStr) else {
            return nil
        }

        let explicit = explicitStr == "yes" ? true : false
        let author = (node |> "itunes:author")?.value
        let link = (node |> "link")?.value
        let site = link != nil ? URL(string: link!) : nil
        var owner: Podcast.Owner?
        if let name = (node |> "ituner:owner" |> "itunes:name")?.value,
            let email = (node |> "ituner:owner" |> "itunes:email")?.value {
            owner = Podcast.Owner(name: name, email: email)
        }

        return Podcast.Show(feedUrl: feedUrl, title: title, description: description, artwork: artwork, categories: [], explicit: explicit, language: language, author: author, site: site, owner: owner)
    }

    private func composeItem(by node: XmlNode) -> Podcast.Episode? {
        guard
            let title = (node |> "title")?.value,
            let enclosureAttributes = (node |> "enclosure")?.attributes,
            let enclosureUrlStr = enclosureAttributes["url"],
            let enclosureUrl = URL(string: enclosureUrlStr),
            let enclosureTypeStr = enclosureAttributes["type"],
            let enclosureType = Enclosure.FileFormat.from(enclosureTypeStr),
            let enclosureLengthStr = enclosureAttributes["length"] else {
            return nil
        }

        let enclosureLength = Int(enclosureLengthStr) ?? 0

        let subTitle = (node |> "itunes:subtitle")?.value
        let guid = (node |> "guid")?.value
        let isPermaLinkStr = (node |> "guid")?.attributes["isPermaLink"]
        var isPermaLink = true
        if guid != nil, let str = isPermaLinkStr, let b = Bool(str) {
            isPermaLink = b
        }

        let enclosure = Enclosure(url: enclosureUrl, length: enclosureLength, type: enclosureType)
        var pubDate: Date?
        if let pubDateStr = (node |> "pubDate")?.value {
            pubDate = parseRfc822DateString(pubDateStr)
        }
        let description = (node |> "description")?.value
        let linkStr = (node |> "link")?.value
        let link = linkStr != nil ? URL(string: linkStr!) : nil
        let duration = parseDuration((node |> "itunes:duration")?.value)

        // TODO: duration, artwork

        return Podcast.Episode(guid: guid, guidIsPermaLink: isPermaLink, title: title, subTitle: subTitle, enclosure: enclosure, pubDate: pubDate, description: description, duration: duration, link: link, artwork: nil)
    }

    // TODO: duration の表現は他にもあるので対応したい
    private func parseDuration(_ str: String?) -> Double? {
        guard let durationStr = str else { return nil }

        // TODO: 数値変換に失敗した際の処理
        let parts = durationStr.split(separator: ":").reversed().map { Int($0)! }

        let duration = parts.enumerated().reduce(0) { prev, val in
            prev + Double(val.element) * NSDecimalNumber(decimal: pow(60, val.offset)).doubleValue
        }
        return duration
    }
}
