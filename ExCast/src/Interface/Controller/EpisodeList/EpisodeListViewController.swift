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
import Common

class EpisodeListViewController: UIViewController {
    typealias Factory = ViewControllerFactory & EpisodePlayerModalContainerFactory

    @IBOutlet var episodeListView: EpisodeListView!
    private let dataSourceContainer = EpisodeListViewDataSourceContainer()

    private let factory: Factory
    private let viewModel: EpisodeListViewModel
    private lazy var playerModalContainerView = self.factory.makeEpisodePlayerModalContainerView()

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
            .flatMap { [unowned self] query -> Single<[AnimatableSectionModel<String, ListingEpisode>]> in
                switch query {
                case let .contents(container):
                    debugLog("The \(self.viewModel.show.title)'s episodes list is updated.")
                    return .just(container)
                default:
                    return .never()
                }
            }
            .bind(to: episodeListView.rx.items(dataSource: dataSourceContainer.dataSource))
            .disposed(by: disposeBag)

        episodeListView.rx.itemSelected
            .bind(onNext: { [unowned self] indexPath in
                self.viewModel.didSelectEpisode(at: indexPath)
            })
            .disposed(by: disposeBag)

        episodeListView.refreshControl?.rx.controlEvent(.valueChanged)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [unowned self] _ in
                debugLog("refresh")
                self.viewModel.fetch()
            })
            .disposed(by: disposeBag)

        viewModel.episodes
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [unowned self] query in
                switch query {
                case .progress:
                    DispatchQueue.main.async {
                        self.episodeListView.refreshControl?.beginRefreshing()
                    }
                default:
                    DispatchQueue.main.async {
                        self.episodeListView.refreshControl?.endRefreshing()
                    }
                }
            }).disposed(by: disposeBag)

        playerModalContainerView?.playingEpisode
            .bind(to: viewModel.playingEpisode)
            .disposed(by: disposeBag)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        viewModel.fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = viewModel.show.title
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

extension EpisodeListViewController: EpisodeListViewProtocol {
    // MARK: - EpisodeListViewProtocol

    func expandPlayer() {
        self.playerModalContainerView?.playerModal?.changeToFullScreenIfPossible()
    }

    func presentPlayer(of episode: Episode) {
        self.playerModalContainerView?.presentPlayerModal(show: viewModel.show, episode: episode)
    }

    func deselectRow(completion: @escaping () -> Void) {
        guard let selectedRow = self.episodeListView.indexPathForSelectedRow else {
            completion()
            return
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.episodeListView.beginUpdates()
            self.episodeListView.deselectRow(at: selectedRow, animated: true)
            self.episodeListView.endUpdates()
        }, completion: { _ in completion() })
    }
}
