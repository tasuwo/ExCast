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
        // let bundle = Bundle.main
        // bundle.loadNibNamed("PodcastShowListView", owner: self, options: nil)

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

        // TODO: イメージどう格納するか考える
        guard let data = try? Data(contentsOf: show.artwork) else {
            return cell
        }
        let image = UIImage(data: data)

        podcastShowCell.layout(artwork: image, title: show.title, author: show.author)

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
