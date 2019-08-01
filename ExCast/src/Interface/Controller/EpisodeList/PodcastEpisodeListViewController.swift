//
//  PodcastEpisodeListViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents

class PodcastEpisodeListViewController: UIViewController {

    @IBOutlet weak var episodeListView: PodcastEpisodeListView!

    private unowned let layoutController: EpisodePlayerModalLaytoutController
    private var viewModel: EpisodeListViewModel

    // MARK: - Initializer

    init(layoutController: EpisodePlayerModalLaytoutController,
         podcast: Podcast) {
        self.layoutController = layoutController
        // TODO: DI
        self.viewModel = EpisodeListViewModel(podcast: podcast, repository: PodcastGateway(session: URLSession.shared, factory: PodcastFactory(), repository: LocalRepositoryImpl(defaults: UserDefaults.standard)))

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.episodeListView.delegate_ = self

        viewModel.episodes ->> self.episodeListView.contentsBond

        viewModel.setup()

        // TODO: 多言語対応
        self.title = self.viewModel.show.value.title

        self.viewModel.loadIfNeeded() { result in
            if !result {
                let message = MDCSnackbarMessage(text: "Failed to load episodes.")
                MDCSnackbarManager.show(message)
            }
        }
    }

}

extension PodcastEpisodeListViewController: PodcastEpisodeListViewDelegate {

    // MARK: - PodcastEpisodeListViewDelegate

    func podcastEpisodeListView(didSelect episode: Podcast.Episode, at index: Int) {
        layoutController.show(show: self.viewModel.show.value, episode: episode)
    }

    func podcastEpisodeListView(shouldUpdate episodes: [Podcast.Episode], completion: @escaping () -> Void) {
        self.viewModel.loadIfNeeded { result in
            if !result {
                let message = MDCSnackbarMessage(text: "Failed to load episodes.")
                MDCSnackbarManager.show(message)
            }

            completion()
        }
    }

    func podcastEpisodeListView(didTapInformationViewOf episode: Podcast.Episode) {
        Swift.print("tapped")
    }

}
