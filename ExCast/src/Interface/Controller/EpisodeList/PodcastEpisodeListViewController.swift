//
//  PodcastEpisodeListViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import RxCocoa
import RxSwift
import UIKit

class PodcastEpisodeListViewController: UIViewController {
    @IBOutlet var episodeListView: PodcastEpisodeListView!
    private let dataSourceContainer = PodcastEpisodeListViewDataSourceContainer()

    private unowned let playerPresenter: EpisodePlayerPresenter
    private var viewModel: EpisodeListViewModel

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(playerPresenter: EpisodePlayerPresenter, podcast _: Podcast, viewModel: EpisodeListViewModel) {
        self.playerPresenter = playerPresenter
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playerPresenter.setDelegate(self)

        dataSourceContainer.delegate = self

        viewModel.episodes
            .bind(to: episodeListView.rx.items(dataSource: dataSourceContainer.dataSource))
            .disposed(by: disposeBag)

        episodeListView.rx.itemSelected
            .bind(onNext: didSelectEpisode(at:))
            .disposed(by: disposeBag)

        episodeListView.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] _ in self?.viewModel.load() })
            .disposed(by: disposeBag)

        viewModel.service.state
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [self] query in
                switch query {
                case .content(_), .error:
                    self.episodeListView.refreshControl?.endRefreshing()
                case .progress:
                    self.episodeListView.refreshControl?.beginRefreshing()
                }
            }).disposed(by: disposeBag)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = viewModel.podcast.value.show.title

        if let selectedRow = self.episodeListView.indexPathForSelectedRow {
            episodeListView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Methods

    func didSelectEpisode(at indexPath: IndexPath) {
        let episode = viewModel.episodes.value(at: indexPath)

        // TODO: Inject player configuration
        playerPresenter.show(show: viewModel.podcast.value.show, episode: episode, configuration: PlayerConfiguration.default)
    }
}

extension PodcastEpisodeListViewController: PodcastEpisodeCellDelegate {
    // MARK: - PodcastEpisodeCellDelegate

    func podcastEpisodeCell(_: UITableViewCell, didSelect episode: Podcast.Episode) {
        guard let navC = self.navigationController else { return }
        navC.pushViewController(
            EpisodeDetailViewController(viewModel: EpisodeDetailViewModel(show: viewModel.podcast.value.show, episode: episode)),
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
