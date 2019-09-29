//
//  PodcastShowListView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class PodcastShowListView: UITableView {
    static let identifier = "podcastShowCell"

    // MARK: - Initializers

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let nib = UINib(nibName: "PodcastShowCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: PodcastShowListView.identifier)
    }

}
