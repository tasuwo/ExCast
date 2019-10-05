//
//  PodcastEpisodeListViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents
import RxCocoa
import RxSwift

class PodcastEpisodeListViewController: UIViewController {

    @IBOutlet weak var episodeListView: PodcastEpisodeListView!
    private let dataSourceContainer = PodcastEpisodeListViewDataSourceContainer()

    private unowned let playerPresenter: EpisodePlayerPresenter
    private var viewModel: EpisodeListViewModel

    private let disposeBag = DisposeBag()

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

        self.playerPresenter.setDelegate(self)
        self.dataSourceContainer.delegate = self

        self.viewModel.episodes
            .bind(to: self.episodeListView.rx.items(dataSource: self.dataSourceContainer.dataSource))
            .disposed(by: self.disposeBag)

        self.episodeListView.rx.itemSelected
            .bind(onNext: self.didSelectEpisode(at:))
            .disposed(by: self.disposeBag)

        if let refreshControl = self.episodeListView.refreshControl {
            refreshControl.rx.controlEvent(.valueChanged)
                .bind(onNext: { [weak self] _ in
                    self?.viewModel.load { result in
                        if !result {
                            let message = MDCSnackbarMessage(text: NSLocalizedString("PodcastShowListView.error", comment: ""))
                            MDCSnackbarManager.show(message)
                        }
                        DispatchQueue.main.async {
                            refreshControl.endRefreshing()
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }
        // viewModel.playingEpisode.accept(self.playerPresenter.playingEpisode())

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewModel.load { _ in }
        self.title = self.viewModel.show.value.title
    }

    func didSelectEpisode(at indexPath: IndexPath) {
        let episode = self.viewModel.episodes.value(at: indexPath)
        self.playerPresenter.show(show: self.viewModel.show.value, episode: episode)
    }

}

extension PodcastEpisodeListViewController: PodcastEpisodeCellDelegate {
    // MARK: - PodcastEpisodeCellDelegate

    func podcastEpisodeCell(_ cell: UITableViewCell, didSelect episode: Podcast.Episode) {
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
        // self.viewModel.playingEpisode = nil
    }

}
