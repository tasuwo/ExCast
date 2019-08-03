//
//  EpisodeDetailViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class EpisodeDetailViewController: UIViewController {

    @IBOutlet weak var episodeDetailView: EpisodeDetailView!
    private let viewModel: EpisodeDetailViewModel

    // MARK: - Initializer

    init(viewModel: EpisodeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.title ->> self.episodeDetailView.episodeTitleLabel
        // TODO:
        self.viewModel.pubDate.map { date in
            if let date = date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
            return ""
        } ->> self.episodeDetailView.episodePubDateLabel
        self.viewModel.duration.map { d in d.asTimeString() ?? "" } ->> self.episodeDetailView.episodeDurationLabel
        self.viewModel.thumbnail ->> self.episodeDetailView.episodeThumbnailView!
        self.viewModel.description ->> self.episodeDetailView.episodeDescriptionLabel.htmlBond

        self.viewModel.setup()
    }

}
