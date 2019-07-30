//
//  PodcastEpisodeListView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol PodcastEpisodeListViewDelegate: AnyObject {
    func podcastEpisodeListView(didSelect episode: Podcast.Episode, at index: Int)
}

class PodcastEpisodeListView: UITableView {

    static let identifier = "podcastEpisodeCell"

    private var episodesCache: [Podcast.Episode] = []
    weak var delegate_: PodcastEpisodeListViewDelegate?

    // MARK: - Initializers

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.loadFromNib()

        // TODO: Presenter に移譲する
        self.delegate = self
        self.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()

        // TODO: Presenter に移譲する
        self.delegate = self
        self.dataSource = self
    }

    // MARK: - Methods

    private func loadFromNib() {
        // let bundle = Bundle.main
        // bundle.loadNibNamed("PodcastShowListView", owner: self, options: nil)

        let nib = UINib(nibName: "PodcastEpisodeCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: PodcastEpisodeListView.identifier)
    }

}


extension PodcastEpisodeListView: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodesCache.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastEpisodeListView.identifier, for: indexPath)
        let episode = episodesCache[indexPath.item]

        guard let episodeCell = cell as? PodcastEpisodeCell else {
            return cell
        }

        episodeCell.layout(title: episode.title, pubDate: episode.pubDate, description: episode.description ?? "", duration: (episode.duration!).asTimeString())

        return cell
    }
}


extension PodcastEpisodeListView: UITableViewDelegate {

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item
        self.deselectRow(at: indexPath, animated: true)
        self.delegate_?.podcastEpisodeListView(didSelect: self.episodesCache[index], at: index)
    }

}

extension PodcastEpisodeListView: BondableTableView {

    // MARK: - BondableTableView

    typealias ContentType = Podcast.Episode

    var contents: Array<Podcast.Episode> {
        get {
            return self.episodesCache
        }
        set {
            self.episodesCache = newValue
        }
    }
}
