//
//  PodcastEpisodeListViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//
import UIKit

class PodcastEpisodeListViewController: UIViewController {

    @IBOutlet weak var episodeListView: PodcastEpisodeListView!

    private unowned let layoutController: EpisodePlayerModalLaytoutController
    private unowned let modalViewDelegate: EpisodePlayerModalViewDelegate
    private var viewModel: EpisodeListViewModel

    // MARK: - Initializer

    init(layoutController: EpisodePlayerModalLaytoutController,
         modalViewDelegate: EpisodePlayerModalViewDelegate,
         podcast: Podcast) {
        self.layoutController = layoutController
        self.modalViewDelegate = modalViewDelegate
        // TODO: DI
        self.viewModel = EpisodeListViewModel(podcast: podcast, repository: PodcastGateway(session: URLSession.shared, factory: PodcastFactory(), repository: LocalRepositoryImpl(defaults: UserDefaults.standard)))

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        self.episodeListView.delegate_ = self

        viewModel.episodes ->> self.episodeListView.contentsBond

        viewModel.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.loadIfNeeded()
    }

}

extension PodcastEpisodeListViewController: PodcastEpisodeListViewDelegate {

    // MARK: - PodcastEpisodeListViewDelegate

    func podcastEpisodeListView(didSelect episode: Podcast.Episode, at index: Int) {
        layoutController.show(episode: episode)
    }

}
