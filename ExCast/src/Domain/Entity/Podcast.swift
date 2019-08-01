//
//  Podcast.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

/// https://help.apple.com/itc/podcasts_connect/#/itcb54353390
struct Podcast: Codable, Equatable {
    
    /// MARK: - Properties
    
    struct Owner: Codable, Equatable {
        let name: String
        let email: String
    }
    
    struct Show: Codable, Equatable {
        let feedUrl: URL
        
        /// The show title.
        let title: String
        
        /// The show description.
        let description: String
        
        /// The artwork for the show.
        let artwork: URL
        
        /// The show category information. For a complete list of categories and subcategories, see [Apple Podcasts categories](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12).
        let categories: [String]
        
        /// The podcast parental advisory information.
        let explicit: Bool
        
        /// The language spoken on the show.
        let language: Language
        
        /// The group responsible for creating the show.
        let author: String?
        
        /// The website associated with a podcast.
        let site: URL?
        
        /// The podcast owner contact information.
        let owner: Owner?
    }

    struct Episode: Codable, Equatable {
        /// The string that uniquely identifies the episode.
        let guid: String?

        /// If this value is false, the guid assumed to be a url.
        let guidIsPermaLink: Bool?

        /// An episode title.
        let title: String
        
        /// The episode content, file size, and file type information.
        let enclosure: Enclosure
        
        /// The date and time when an episode was released.
        let pubDate: Date?
        
        /// An episode description.
        let description: String?
        
        /// The duration of an episode.
        /// Different duration formats are accepted.
        let duration: Double?
        
        /// An episode link URL.
        let link: URL?
        
        /// The episode artwork.
        let artwork: URL?
    }

    let show: Show
    var episodes: [Episode]
    
}
