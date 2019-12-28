//
//  EpisodeListViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import MaterialComponents
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class EpisodeListViewController: UIViewController {
    typealias Factory = ViewControllerFactory & EpisodePlayerModalPresenterFactory

    @IBOutlet var episodeListView: EpisodeListView!
    private let dataSourceContainer = EpisodeListViewDataSourceContainer()

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

        dataSourceContainer.delegate = self

        viewModel.episodes
            .flatMap { query -> Single<[AnimatableSectionModel<String, EpisodeListViewModel.ListingEpisode>]> in
                switch query {
                case let .contents(episodeContainer):
                    return Single.just(episodeContainer)
                case .error, .progress:
                    return Single.never()
                }
            }
            .bind(to: episodeListView.rx.items(dataSource: dataSourceContainer.dataSource))
            .disposed(by: disposeBag)

        episodeListView.rx.itemSelected
            .bind(onNext: didSelectEpisode(at:))
            .disposed(by: disposeBag)

        episodeListView.refreshControl?.rx.controlEvent(.valueChanged)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [unowned self] _ in self.viewModel.fetch() })
            .disposed(by: disposeBag)

        viewModel.episodes
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [self] query in
                switch query {
                case .contents(_), .error:
                    DispatchQueue.main.async {
                        self.episodeListView.refreshControl?.endRefreshing()
                    }
                case .progress:
                    DispatchQueue.main.async {
                        self.episodeListView.refreshControl?.beginRefreshing()
                    }
                }
            }).disposed(by: disposeBag)

        playerPresenter?.playingEpisode
            .bind(to: viewModel.playingEpisode)
            .disposed(by: disposeBag)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        viewModel.fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = viewModel.show.title

        if let selectedRow = self.episodeListView.indexPathForSelectedRow {
            episodeListView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Methods

    func didSelectEpisode(at indexPath: IndexPath) {
        playerPresenter?.show(show: viewModel.show,
                              episode: viewModel.episodesCache.value(at: indexPath).episode)
    }
}

extension EpisodeListViewController: EpisodeCellDelegate {
    // MARK: - EpisodeCellDelegate

    func podcastEpisodeCell(_: UITableViewCell, didSelect episode: Episode) {
        guard let navigationController = self.navigationController else { return }

        let nextViewController = factory.makeEpisodeDetailViewController(show: viewModel.show, episode: episode)
        navigationController.pushViewController(nextViewController, animated: true)
    }
}
