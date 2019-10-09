//
//  PodcastEpisodeListView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import UIKit

class PodcastEpisodeListView: UITableView {
    static let identifier = "podcastEpisodeCell"

    private var episodesCache: [Podcast.Episode] = []
    private var cellHeightCache: [IndexPath: CGFloat] = [:]
    var playingEpisode: Podcast.Episode?

    // MARK: - Initializers

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        loadFromNib()
        refreshControl = UIRefreshControl()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
        refreshControl = UIRefreshControl()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let nib = UINib(nibName: "PodcastEpisodeCell", bundle: nil)
        register(nib, forCellReuseIdentifier: PodcastEpisodeListView.identifier)
    }
}
