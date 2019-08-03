//
//  PodcastEpisodeListView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents

protocol PodcastEpisodeListViewDelegate: AnyObject {

    func podcastEpisodeListView(didSelect episode: Podcast.Episode, at index: Int)

    func podcastEpisodeListView(shouldUpdate episodes: [Podcast.Episode], completion: @escaping () -> Void)

    func podcastEpisodeListView(didTapInformationViewOf episode: Podcast.Episode)

}

class PodcastEpisodeListView: UITableView {

    static let identifier = "podcastEpisodeCell"

    private var episodesCache: [Podcast.Episode] = []
    weak var delegate_: PodcastEpisodeListViewDelegate?

    // MARK: - Initializers

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.loadFromNib()
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
        self.setup()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let nib = UINib(nibName: "PodcastEpisodeCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: PodcastEpisodeListView.identifier)
    }

    private func setup() {
        // TODO: Presenter に移譲する
        self.delegate = self
        self.dataSource = self

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.refreshContents), for: .valueChanged)
    }

    @objc private func refreshContents() {
        DispatchQueue.global(qos: .background).async {
            self.delegate_?.podcastEpisodeListView(shouldUpdate: self.episodesCache) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
            }
        }
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

        episodeCell.episode = episode
        episodeCell.layout(title: episode.title, pubDate: episode.pubDate, description: episode.description, duration: episode.duration)
        episodeCell.delegate = self

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

extension PodcastEpisodeListView: PodcastEpisodeCellDelegate {

    // MARK: - PodcastEpisodeCellDelegate

    func podcastEpisodeCell(_ cell: UITableViewCell, didSelect episode: Podcast.Episode) {
        self.delegate_?.podcastEpisodeListView(didTapInformationViewOf: episode)
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
