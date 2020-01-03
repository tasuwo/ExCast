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
    typealias Factory = ViewControllerFactory & ViewModelFactory & EpisodePlayerModalBaseViewFactory

    @IBOutlet var modalView: EpisodePlayerModalView!

    private let factory: Factory
    private lazy var playerBaseView = self.factory.makeEpisodePlayerModalBaseView()
    private let modalViewModel: PlayerModalViewModel
    private var controllerViewModel: PlayerControllerViewModel!
    private var informationViewModel: PlayerInformationViewModel!
    private weak var playingEpisodeViewModel: PlayingEpisodeViewModel?

    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(factory: Factory, show: Channel, episode: Episode, viewModel: PlayerModalViewModel, playingEpisodeViewModel: PlayingEpisodeViewModel) {
        self.factory = factory
        modalViewModel = viewModel
        controllerViewModel = factory.makePlayerControllerViewModel(show: show, episode: episode)
        informationViewModel = factory.makePlayerInformationViewModel(show: show, episode: episode)
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
            .bind(onNext: { [unowned self] state in
                switch state {
                case .fullscreen:
                    self.modalView.expand()
                case .mini:
                    self.modalView.minimize()
                case .hide:
                    self.dismissPlayerBaseView()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        bindEpisode()
    }

    // MARK: - Methods

    func reload(controllerViewModel: PlayerControllerViewModel,
                informationViewModel: PlayerInformationViewModel) {
        self.controllerViewModel = nil
        self.controllerViewModel = controllerViewModel
        self.informationViewModel = nil
        self.informationViewModel = informationViewModel

        bindEpisode()
    }

    private func bindEpisode() {
        self.playingEpisodeViewModel?.set(self.informationViewModel.episode,
                                          belongsTo: self.informationViewModel.show)
        self.controllerViewModel.createdPlayer
            .map { !$0 }
            .bind(to: self.playingEpisodeViewModel!.isLoading)
            .disposed(by: self.disposeBag)
        self.controllerViewModel.currentTime
            .bind(to: self.playingEpisodeViewModel!.currentDuration)
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
