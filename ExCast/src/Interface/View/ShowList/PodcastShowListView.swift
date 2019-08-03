//
//  PodcastShowListView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol PodcastShowListViewDelegate: AnyObject {
    func podcastShowListView(didSelect show: Podcast, at index: Int)
    func podcastShowListView(didDelete show: Podcast, at index: Int)
}

class PodcastShowListView: UITableView {

    static let identifier = "podcastShowCell"

    private var cache: [Podcast] = []
    private var thumbnailCache: [IndexPath:UIImage] = [:]
    private var thumbnailDownloadersInProgress: [IndexPath:ThumbnailDownloader] = [:]
    weak var delegate_: PodcastShowListViewDelegate?

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
        let nib = UINib(nibName: "PodcastShowCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: PodcastShowListView.identifier)
    }

}

extension PodcastShowListView: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cache.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastShowListView.identifier, for: indexPath)
        let show = cache[indexPath.item].show

        guard let podcastShowCell = cell as? PodcastShowCellProtocol else {
            return cell
        }

        if let thumbnail = self.thumbnailCache[indexPath] {
            podcastShowCell.layout(artwork: thumbnail, title: show.title, author: show.author)
            return cell
        } else if let _ = self.thumbnailDownloadersInProgress[indexPath] {
            podcastShowCell.layout(artwork: nil, title: show.title, author: show.author)
            return cell
        }

        let url = show.artwork
        let downloader = ThumbnailDownloader(size: 90)
        self.thumbnailDownloadersInProgress[indexPath] = downloader

        downloader.startDownload(by: url, at: indexPath) { [weak self] index, result in
            guard let self = self else { return }

            switch result {
            case let .success(image):
                // TODO:
                guard let cell = self.cellForRow(at: index) as? PodcastShowCell else { return }
                cell.showArtwork.image = image
                cell.setNeedsLayout()
                self.thumbnailDownloadersInProgress.removeValue(forKey: index)
            case .failure(_):
                // TODO:
                break
            }
        }

        podcastShowCell.layout(artwork: nil, title: show.title, author: show.author)

        return cell
    }
}

extension PodcastShowListView: UITableViewDelegate {

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item
        self.deselectRow(at: indexPath, animated: true)
        self.delegate_?.podcastShowListView(didSelect: self.cache[index], at: index)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.item
            self.delegate_?.podcastShowListView(didDelete: self.cache[index], at: index)
        }
    }
}

extension PodcastShowListView: BondableTableView {

    // MARK: - BondableTableView

    typealias ContentType = Podcast

    var contents: Array<Podcast> {
        get {
            return self.cache
        }
        set {
            self.cache = newValue
        }
    }
}
