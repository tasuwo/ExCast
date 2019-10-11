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
    typealias Factory = ViewControllerFactory & EpisodePlayerModalPresenterFactory

    @IBOutlet var episodeListView: PodcastEpisodeListView!
    private let dataSourceContainer = PodcastEpisodeListViewDataSourceContainer()

    private let factory: Factory
    private let viewModel: EpisodeListViewModel
    private lazy var playerPresenter = self.factory.makeEpisodePlayerModalPresenter()

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(factory: Factory, viewModel: EpisodeListViewModel) {
        self.factory = factory
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.playerPresenter?.setDelegate(self)

        self.dataSourceContainer.delegate = self

        self.viewModel.episodes
            .bind(to: episodeListView.rx.items(dataSource: dataSourceContainer.dataSource))
            .disposed(by: disposeBag)

        self.episodeListView.rx.itemSelected
            .bind(onNext: didSelectEpisode(at:))
            .disposed(by: disposeBag)

        self.episodeListView.refreshControl?.rx.controlEvent(.valueChanged)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [unowned self] _ in self.viewModel.fetch(url: self.viewModel.podcast.value.show.feedUrl) })
            .disposed(by: disposeBag)

        self.viewModel.state
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [self] query in
                switch query {
                case .normal, .error:
                    self.episodeListView.refreshControl?.endRefreshing()
                case .progress:
                    self.episodeListView.refreshControl?.beginRefreshing()
                }
            }).disposed(by: disposeBag)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        self.viewModel.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = self.viewModel.podcast.value.show.title

        if let selectedRow = self.episodeListView.indexPathForSelectedRow {
            self.episodeListView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Methods

    func didSelectEpisode(at indexPath: IndexPath) {
        let episode = viewModel.episodes.value(at: indexPath)
        self.playerPresenter?.show(show: viewModel.podcast.value.show, episode: episode)
    }
}

extension PodcastEpisodeListViewController: PodcastEpisodeCellDelegate {
    // MARK: - PodcastEpisodeCellDelegate

    func podcastEpisodeCell(_: UITableViewCell, didSelect episode: Podcast.Episode) {
        guard let navigationController = self.navigationController else { return }

        let nextViewController = self.factory.makeEpisodeDetailViewController(show: self.viewModel.podcast.value.show, episode: episode)
        navigationController.pushViewController(nextViewController, animated: true)
    }
}

extension PodcastEpisodeListViewController: EpisodePlayerPresenterDelegate {
    // MARK: - EpisodePlayerPresenterDelegate

    func didDismissPlayer() {
        // self.viewModel.playingEpisode = nil
    }
}
