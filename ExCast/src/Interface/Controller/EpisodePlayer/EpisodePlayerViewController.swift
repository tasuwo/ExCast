//
//  EpisodePlayerViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

protocol EpisodePlayerModalBaseViewProtocol: AnyObject {
    func dismiss()
    func minimize()
    func expand()
}

class EpisodePlayerViewController: UIViewController {
    // MARK: - Type Aliases

    typealias Factory = ViewControllerFactory & ViewModelFactory & EpisodePlayerModalBaseViewFactory

    // MARK: - Properties

    private let factory: Factory
    private lazy var playerBaseView = self.factory.makeEpisodePlayerModalBaseView()
    private let modalViewModel: PlayerModalViewModel
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var controllerViewModel: PlayerControllerViewModel!
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var informationViewModel: PlayerInformationViewModel!
    private weak var playingEpisodeViewModel: PlayingEpisodeViewModel?

    private var disposeBag = DisposeBag()

    // MARK: - IBOutlets

    @IBOutlet var modalView: EpisodePlayerModalView!

    // MARK: - Lifecycle

    init(factory: Factory, id: Podcast.Identity, show: Channel, episode: Episode, playbackSec: Double?, viewModel: PlayerModalViewModel, playingEpisodeViewModel: PlayingEpisodeViewModel) {
        self.factory = factory
        modalViewModel = viewModel
        controllerViewModel = factory.makePlayerControllerViewModel(show: show, episode: episode, playbackSec: playbackSec)
        informationViewModel = factory.makePlayerInformationViewModel(id: id, show: show, episode: episode)
        self.playingEpisodeViewModel = playingEpisodeViewModel
        self.playingEpisodeViewModel?.isLoading.accept(true)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        modalView.delegate = self
        modalView.seekBar.delegate = self
        modalView.playbackButtons.delegate = self

        modalViewModel.modalState
            .bind(onNext: { [weak self] state in
                switch state {
                case .fullscreen:
                    self?.modalView.expand()

                case .mini:
                    self?.modalView.minimize()

                case .hide:
                    self?.dismissPlayerBaseView()

                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        if let dependency = self.playingEpisodeViewModel {
            self.bind(to: dependency)
        }
    }

    // MARK: - Methods

    func reload(controllerViewModel: PlayerControllerViewModel,
                informationViewModel: PlayerInformationViewModel) {
        self.controllerViewModel = nil
        self.controllerViewModel = controllerViewModel
        self.informationViewModel = nil
        self.informationViewModel = informationViewModel

        if let dependency = self.playingEpisodeViewModel {
            self.bind(to: dependency)
        }
    }

    private func bind(to dependency: PlayingEpisodeViewModel) {
        dependency.set(id: self.informationViewModel.id,
                       episode: self.informationViewModel.episode,
                       belongsTo: self.informationViewModel.show,
                       playbackSec: self.controllerViewModel.initialPlaybackSec)
        self.controllerViewModel.createdPlayer
            .map { !$0 }
            .bind(to: dependency.isLoading)
            .disposed(by: self.disposeBag)
        self.controllerViewModel.currentTime
            .compactMap { currentTime in
                dependency.playingEpisode.value?.updated(playbackSec: currentTime)
            }
            .bind(to: dependency.playingEpisode)
            .disposed(by: self.disposeBag)

        informationViewModel.showTitle
            .bind(to: modalView.rx.showTitle)
            .disposed(by: disposeBag)
        informationViewModel.episodeTitle
            .bind(to: modalView.rx.episodeTitle)
            .disposed(by: disposeBag)
        informationViewModel.thumbnail
            .compactMap { $0 }
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap { UIImage(data: $0) }
            .bind(to: modalView.rx.thumbnail)
            .disposed(by: disposeBag)

        controllerViewModel.duration
            .bind(to: modalView.rx.duration)
            .disposed(by: disposeBag)
        controllerViewModel.isPrepared
            .bind(to: modalView.rx.isPlaybackEnabled)
            .disposed(by: disposeBag)
        controllerViewModel.isPlaying
            .bind(to: modalView.rx.isPlaying)
            .disposed(by: disposeBag)
        controllerViewModel.displayCurrentTime
            .bind(to: modalView.rx.currentTime)
            .disposed(by: disposeBag)
    }
}

extension EpisodePlayerViewController: EpisodePlayerPlaybackButtonsDelegate {
    // MARK: EpisodePlayerPlaybackButtonsDelegate

    func didTapPlaybackButton() {
        controllerViewModel.playback()
    }

    func didTapSkipForwardButton() {
        controllerViewModel.skipForward()
    }

    func didTapSkipBackwardButton() {
        controllerViewModel.skipBackward()
    }
}

extension EpisodePlayerViewController: EpisodePlayerSeekBarContainerDelegate {
    // MARK: - EpisodePlayerSeekBarContainerDelegate

    func didStartSeek() {
        controllerViewModel.isSliderGrabbed.accept(true)
    }

    func didEndSeek() {
        controllerViewModel.isSliderGrabbed.accept(false)
    }

    func didChangeSeekValue(to time: TimeInterval) {
        controllerViewModel.displayCurrentTime.accept(time)
    }
}

extension EpisodePlayerViewController: EpisodePlayerModalViewDelegate {
    // MARK: - EpisodePlayerModalViewDelegate

    func dismissPlayerBaseView() {
        self.playerBaseView?.dismiss()
    }

    func minimizePlayerBaseView() {
        self.playerBaseView?.minimize()
    }

    func expandPlayerBaseView() {
        self.playerBaseView?.expand()
    }

    func didTap() {
        modalViewModel.didTap()
    }

    func didPanned(distance: Float, velocity: Float) {
        modalViewModel.panState.accept(.changed(lentgh: distance, velocity: velocity))
    }

    func didEndPanned(distance: Float, velocity: Float) {
        modalViewModel.panState.accept(.ended(length: distance, velocity: velocity))
        modalViewModel.panState.accept(.none)
    }

    func didTapMinimizeButton() {
        modalViewModel.modalState.accept(.mini)
    }
}

extension EpisodePlayerViewController: EpisodePlayerModalProtocol {
    // MARK: - EpisodePlayerViewProtocol

    func changeToFullScreenIfPossible() {
        self.modalViewModel.modalState.accept(.fullscreen)
    }

    func changeToMinimizeIfPossible() {
        self.modalViewModel.modalState.accept(.mini)
    }
}
