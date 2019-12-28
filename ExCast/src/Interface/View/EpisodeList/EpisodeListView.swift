//
//  PodcastEpisodeListView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import UIKit

class EpisodeListView: UITableView {
    static let identifier = "podcastEpisodeCell"

    // MARK: - Lifecycle

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
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        register(nib, forCellReuseIdentifier: EpisodeListView.identifier)
    }
}
