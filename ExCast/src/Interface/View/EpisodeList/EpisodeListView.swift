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
        self.applyAppearance()
        self.loadFromNib()
        refreshControl = UIRefreshControl()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyAppearance()
        self.loadFromNib()
        refreshControl = UIRefreshControl()
    }

    // MARK: - Methods

    func update(_ playbackSec: Double?, at indexPath: IndexPath) {
        guard let cell = self.cellForRow(at: indexPath) as? EpisodeCell,
            let currentPlaybackSec = playbackSec else { return }
        cell.currentDuration = currentPlaybackSec
    }

    func showPlayingMarkIcon(at indexPath: IndexPath) {
        guard let cell = self.cellForRow(at: indexPath) as? EpisodeCell else { return }
        cell.playingMarkIconView.isHidden = false
    }

    func hidePlayingMarkIcon(at indexPath: IndexPath) {
        guard let cell = self.cellForRow(at: indexPath) as? EpisodeCell else { return }
        cell.playingMarkIconView.isHidden = true
    }

    // MARK: - Private Methods

    private func loadFromNib() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        register(nib, forCellReuseIdentifier: EpisodeListView.identifier)
    }

    private func applyAppearance() {
        self.rowHeight = 130
    }
}
