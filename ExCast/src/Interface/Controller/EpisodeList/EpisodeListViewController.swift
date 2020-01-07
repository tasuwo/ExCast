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
        self.dataSourceContainer.episodeListViewModel = self.viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSourceContainer.delegate = self

        // MARK: ViewModel > EpisodeListView

        self.viewModel.episodeCells
            .flatMap { [unowned self] query -> Single<[AnimatableSectionModel<String, Episode>]> in
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

        self.viewModel.episodeCells
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [weak self] query in
                guard let self = self else { return }

                switch query {
                case .progress:
                    DispatchQueue.main.async {
                        self.episodeListView.refreshControl?.beginRefreshing()
                    }
                default:
                    DispatchQueue.main.async {
                        if self.episodeListView.refreshControl?.isRefreshing == true {
                            self.episodeListView.refreshControl?.endRefreshing()
                        }
                    }
                }
            }).disposed(by: disposeBag)

        self.viewModel.playingEpisodeCell
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [unowned self] playingEpisode in
                if let indexPath = playingEpisode?.indexPath,
                    let cell = self.episodeListView.cellForRow(at: indexPath) as? EpisodeCell,
                    let currentPlaybackSec = playingEpisode?.currentPlaybackSec,
                    currentPlaybackSec > 0 {
                    cell.currentDuration = currentPlaybackSec
                }
            })
            .disposed(by: self.disposeBag)

        Observable
            .zip(self.viewModel.playingEpisodeCell, self.viewModel.playingEpisodeCell.skip(1))
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [unowned self] diff  in
                switch diff {
                case let (.none, .some(current)):
                    guard let cell = self.episodeListView.cellForRow(at: current.indexPath) as? EpisodeCell else { return }
                    cell.playingMarkIconView.isHidden = false
                case let (.some(prev), .some(current)):
                    guard let currentCell = self.episodeListView.cellForRow(at: current.indexPath) as? EpisodeCell,
                        let prevCell = self.episodeListView.cellForRow(at: prev.indexPath) as? EpisodeCell else { return }
                    prevCell.playingMarkIconView.isHidden = true
                    currentCell.playingMarkIconView.isHidden = false
                case let (.some(prev), .none):
                    guard let cell = self.episodeListView.cellForRow(at: prev.indexPath) as? EpisodeCell else { return }
                    cell.playingMarkIconView.isHidden = true
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)

        // MARK: EpisodeListView > ViewModel

        self.episodeListView.rx.itemSelected
            .bind(onNext: { [unowned self] indexPath in
                self.viewModel.didSelectEpisode(at: indexPath)
            })
            .disposed(by: disposeBag)

        self.episodeListView.refreshControl?.rx.controlEvent(.valueChanged)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(onNext: { [unowned self] _ in
                debugLog("refresh")
                self.viewModel.fetch()
            })
            .disposed(by: disposeBag)


        // MARK: PlayerModalContainerView > ViewModel

        self.playerModalContainerView?.playingEpisode
            .bind(to: viewModel.playingEpisode)
            .disposed(by: disposeBag)

        self.playerModalContainerView?.playingEpisodesPlaybackSec
            .bind(to: self.viewModel.playingEpisodesPlaybackSec)
            .disposed(by: self.disposeBag)


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

    func presentPlayer(of listingEpisode: ListingEpisode) {
        self.playerModalContainerView?.presentPlayerModal(id: self.viewModel.id, show: self.viewModel.show, episode: listingEpisode.episode, playbackSec: listingEpisode.displayingPlaybackSec)
    }

    func deselectRow() {
        guard let selectedRow = self.episodeListView.indexPathForSelectedRow else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.episodeListView.beginUpdates()
            self.episodeListView.deselectRow(at: selectedRow, animated: true)
            self.episodeListView.endUpdates()
        }, completion: { _ in })
    }
}
