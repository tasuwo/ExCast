//
//  EpisodeListViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Domain
import MaterialComponents
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class EpisodeListViewController: UIViewController {
    // MARK: - Type Aliases

    typealias Factory = ViewControllerFactory & EpisodePlayerModalContainerFactory
    typealias Dependency = EpisodeListViewModelType

    // MARK: - Properties

    private lazy var playerModalContainerView = self.factory.makeEpisodePlayerModalContainerView()

    private let factory: Factory
    private let viewModel: EpisodeListViewModelType
    private let dataSourceContainer = EpisodeListViewDataSourceContainer()

    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets

    @IBOutlet var episodeListView: EpisodeListView!

    // MARK: - Lifecycle

    init(factory: Factory, viewModel: EpisodeListViewModelType) {
        self.factory = factory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.dataSourceContainer.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind(to: self.viewModel)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        self.viewModel.inputs.episodesLoaded.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = self.viewModel.outputs.show.title
    }
}

extension EpisodeListViewController: EpisodeCellDelegate {
    // MARK: - EpisodeCellDelegate

    func podcastEpisodeCell(_: UITableViewCell, didSelect episode: Episode) {
        guard let navigationController = self.navigationController else { return }

        let nextViewController = factory.makeEpisodeDetailViewController(show: self.viewModel.outputs.show, episode: episode)
        navigationController.pushViewController(nextViewController, animated: true)
    }
}

extension EpisodeListViewController {
    // MARK: - Binding

    func bind(to dependency: Dependency) {
        // MARK: Outputs

        dependency.outputs.episodes
            .skip(1)
            .drive(self.episodeListView.rx.items(dataSource: self.dataSourceContainer.dataSource))
            .disposed(by: disposeBag)

        Driver
            .zip(dependency.outputs.isLoading, dependency.outputs.isLoading.skip(1))
            .skip(1)
            .drive(onNext: { [weak self] diff in
                switch diff {
                case (false, true):
                    self?.episodeListView.refreshControl?.beginRefreshing()

                case (true, false):
                    self?.episodeListView.refreshControl?.endRefreshing()

                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)

        dependency.outputs.playingEpisode
            .drive(onNext: { [weak self] episode in
                guard let indexPath = episode?.indexPath else { return }
                self?.episodeListView.update(episode?.currentPlaybackSec, at: indexPath)
            })
            .disposed(by: self.disposeBag)

        dependency.outputs.playingEpisode
            .drive(onNext: { [weak self] episode in
                self?.dataSourceContainer.currentPlayingEpisodeIndex.accept(episode?.indexPath)
            })
            .disposed(by: self.disposeBag)

        Driver
            .zip(dependency.outputs.playingEpisode, dependency.outputs.playingEpisode.skip(1))
            .drive(onNext: { [weak self] diff in
                switch diff {
                case let (.none, .some(current)):
                    self?.episodeListView.showPlayingMarkIcon(at: current.indexPath)

                case let (.some(prev), .some(current)):
                    self?.episodeListView.hidePlayingMarkIcon(at: prev.indexPath)
                    self?.episodeListView.showPlayingMarkIcon(at: current.indexPath)

                case let (.some(prev), .none):
                    self?.episodeListView.hidePlayingMarkIcon(at: prev.indexPath)

                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)

        dependency.outputs.playerExpanded
            .emit(onNext: { [weak self] in
                self?.playerModalContainerView?.playerModal?.changeToFullScreenIfPossible()
            })
            .disposed(by: self.disposeBag)

        dependency.outputs.playerPresented
            .emit(onNext: { [weak self] listingEpisode in
                guard let self = self else { return }
                self.playerModalContainerView?.presentPlayerModal(
                    id: self.viewModel.outputs.id,
                    show: self.viewModel.outputs.show,
                    episode: listingEpisode.episode,
                    playbackSec: listingEpisode.displayingPlaybackSec
                )
            })
            .disposed(by: self.disposeBag)

        dependency.outputs.rowDeselected
            .emit(onNext: { [weak self] in
                guard let self = self,
                    let selectedRow = self.episodeListView.indexPathForSelectedRow else { return }
                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        self.episodeListView.beginUpdates()
                        self.episodeListView.deselectRow(at: selectedRow, animated: true)
                        self.episodeListView.endUpdates()
                    },
                    completion: { _ in }
                )
            })
            .disposed(by: self.disposeBag)

        // MARK: Inputs

        self.episodeListView.rx.itemSelected
            .asSignal()
            .emit(to: dependency.inputs.episodeSelected)
            .disposed(by: disposeBag)

        self.episodeListView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .asSignal()
            .emit(to: dependency.inputs.episodesFetched)
            .disposed(by: self.disposeBag)

        self.playerModalContainerView?.playingEpisode
            .bind(to: dependency.inputs.episodePlayed)
            .disposed(by: self.disposeBag)
    }
}
