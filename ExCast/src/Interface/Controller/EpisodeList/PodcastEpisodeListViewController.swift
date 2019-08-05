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

    private unowned let playerPresenter: EpisodePlayerPresenter
    private var viewModel: EpisodeListViewModel

    // MARK: - Initializer

    init(playerPresenter: EpisodePlayerPresenter,
         podcast: Podcast,
         viewModel: EpisodeListViewModel) {
        self.playerPresenter = playerPresenter
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        Swift.print("list viewcontroller")
                Swift.print(self.view.bounds)

        self.playerPresenter.setDelegate(self)
        self.episodeListView.delegate_ = self

        viewModel.episodes ->> self.episodeListView.contentsBond
        viewModel.playingEpisode ->> self.episodeListView

        viewModel.setup(with: self.playerPresenter.playingEpisode())

        self.title = self.viewModel.show.value.title

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }

}

extension PodcastEpisodeListViewController: PodcastEpisodeListViewDelegate {

    // MARK: - PodcastEpisodeListViewDelegate

    func podcastEpisodeListView(didSelect episode: Podcast.Episode, at index: Int) {
        self.viewModel.playingEpisode.value = episode
        self.playerPresenter.show(show: self.viewModel.show.value, episode: episode)
    }

    func podcastEpisodeListView(shouldUpdate episodes: [Podcast.Episode], completion: @escaping () -> Void) {
        self.viewModel.loadIfNeeded { result in
            if !result {
                let message = MDCSnackbarMessage(text: NSLocalizedString("PodcastShowListView.error", comment: ""))
                MDCSnackbarManager.show(message)
            }

            completion()
        }
    }

    func podcastEpisodeListView(didTapInformationViewOf episode: Podcast.Episode) {
        guard let navC = self.navigationController else { return }
        navC.pushViewController(
            EpisodeDetailViewController(
                viewModel: EpisodeDetailViewModel(
                    show: self.viewModel.show.value,
                    episode: episode
                )
            ),
            animated: true
        )
    }

}

extension PodcastEpisodeListViewController: EpisodePlayerPresenterDelegate {

    // MARK: - EpisodePlayerPresenterDelegate

    func didDismissPlayer() {
        self.viewModel.playingEpisode.value = nil
    }

}
