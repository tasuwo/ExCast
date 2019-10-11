//
//  PodcastEpisodeListViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import RxDataSources
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

        self.dataSourceContainer.delegate = self

        self.viewModel.episodes
            .flatMap({ query -> Single<[AnimatableSectionModel<String, EpisodeListViewModel.ListingEpisode>]> in
                switch query {
                case let .contents(episodeContainer):
                    return Single.just(episodeContainer)
                case .error, .progress:
                    return Single.never()
                }
            })
            .bind(to: episodeListView.rx.items(dataSource: dataSourceContainer.dataSource))
            .disposed(by: disposeBag)

        self.episodeListView.rx.itemSelected
            .bind(onNext: didSelectEpisode(at:))
            .disposed(by: disposeBag)

        self.episodeListView.refreshControl?.rx.controlEvent(.valueChanged)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [unowned self] _ in self.viewModel.fetch(url: self.viewModel.show.feedUrl) })
            .disposed(by: disposeBag)

        self.viewModel.episodes
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [self] query in
                switch query {
                case .contents(_), .error:
                    self.episodeListView.refreshControl?.endRefreshing()
                case .progress:
                    self.episodeListView.refreshControl?.beginRefreshing()
                }
            }).disposed(by: disposeBag)

        self.playerPresenter?.playingEpisode
            .bind(to: self.viewModel.playingEpisode)
            .disposed(by: self.disposeBag)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        self.viewModel.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = self.viewModel.show.title

        if let selectedRow = self.episodeListView.indexPathForSelectedRow {
            self.episodeListView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Methods

    func didSelectEpisode(at indexPath: IndexPath) {
        let episode = self.viewModel.episodesCache.value(at: indexPath).episode
        self.playerPresenter?.show(show: self.viewModel.show, episode: episode)
    }
}

extension PodcastEpisodeListViewController: PodcastEpisodeCellDelegate {
    // MARK: - PodcastEpisodeCellDelegate

    func podcastEpisodeCell(_: UITableViewCell, didSelect episode: Podcast.Episode) {
        guard let navigationController = self.navigationController else { return }

        let nextViewController = self.factory.makeEpisodeDetailViewController(show: self.viewModel.show, episode: episode)
        navigationController.pushViewController(nextViewController, animated: true)
    }
}
