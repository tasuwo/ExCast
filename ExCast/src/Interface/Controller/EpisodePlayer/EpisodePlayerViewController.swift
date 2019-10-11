//
//  EpisodePlayerViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

protocol EpisodePlayerPresenterDelegate: AnyObject {
    func didDismissPlayer()
}

protocol EpisodePlayerModalPresenterProtocol: AnyObject {
    func playingEpisode() -> Podcast.Episode?

    func setDelegate(_ delegate: EpisodePlayerPresenterDelegate)

    func show(show: Podcast.Show, episode: Podcast.Episode)

    func dismiss()

    func minimize()

    func expand()
}

class EpisodePlayerViewController: UIViewController {
    typealias Factory = ViewControllerFactory & ViewModelFactory & EpisodePlayerModalPresenterFactory

    @IBOutlet var modalView: EpisodePlayerModalView!

    var playingEpisode: Podcast.Episode {
        return informationViewModel.episode
    }

    private let factory: Factory
    private lazy var playerModalPresenter = self.factory.makeEpisodePlayerModalPresenter()
    private let modalViewModel: PlayerModalViewModel
    private var controllerViewModel: PlayerControllerViewModel!
    private var informationViewModel: PlayerInformationViewModel!

    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(factory: Factory, show: Podcast.Show, episode: Podcast.Episode, viewModel: PlayerModalViewModel) {
        self.factory = factory
        self.modalViewModel = viewModel
        self.controllerViewModel = factory.makePlayerControllerViewModel(show: show, episode: episode)
        self.informationViewModel = factory.makePlayerInformationViewModel(show: show, episode: episode)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate

        modalView.delegate = self
        modalView.seekBar.delegate = self
        modalView.playbackButtons.delegate = self

        // Bind

        modalViewModel.modalState
            .bind(onNext: { [unowned self] state in
                switch state {
                case .fullscreen:
                    self.modalView.expand()
                case .mini:
                    self.modalView.minimize()
                case .hide:
                    self.shouldDismiss()
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
        let length = controllerViewModel.episodeLength
        modalView.seekBar.bar.maximumValue = CGFloat(length)

        // Bind

        informationViewModel.showTitle
            .bind(to: modalView.showTitleLabel.rx.text)
            .disposed(by: disposeBag)
        informationViewModel.episodeTitle
            .bind(to: modalView.episodeTitleLabel.rx.text)
            .disposed(by: disposeBag)
        informationViewModel.thumbnail
            .compactMap { $0 }
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap { UIImage(data: $0) }
            .bind(to: modalView.thumbnailImageView.rx.image)
            .disposed(by: disposeBag)

        controllerViewModel.isPrepared
            .bind(to: modalView.playbackButtons.playbackButton.rx.isEnabled)
            .disposed(by: disposeBag)
        controllerViewModel.isPrepared
            .bind(to: modalView.playbackButtons.forwardSkipButton.rx.isEnabled)
            .disposed(by: disposeBag)
        controllerViewModel.isPrepared
            .bind(to: modalView.playbackButtons.backwardSkipButton.rx.isEnabled)
            .disposed(by: disposeBag)
        controllerViewModel.isPlaying
            .compactMap { isPlaying -> UIImage? in
                if isPlaying {
                    return UIImage(named: "player_pause")
                } else {
                    return UIImage(named: "player_playback")
                }
            }
            .bind(to: modalView.playbackButtons.playbackButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        controllerViewModel.displayCurrentTime
            .compactMap { $0.asTimeString() }
            .bind(to: modalView.seekBar.currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
        controllerViewModel.displayCurrentTime
            .compactMap { (Float($0) - length).asTimeString() }
            .bind(to: modalView.seekBar.remainingTimeLabel.rx.text)
            .disposed(by: disposeBag)
        controllerViewModel.displayCurrentTime
            .map { CGFloat($0) }
            .bind(onNext: { [weak self] time in self?.modalView.seekBar.bar.value = time })
            .disposed(by: disposeBag)

        controllerViewModel.setup()
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

    func shouldDismiss() {
        self.playerModalPresenter?.dismiss()
    }

    func shouldMinimize() {
        self.playerModalPresenter?.minimize()
    }

    func shouldExpand() {
        self.playerModalPresenter?.expand()
    }

    func didTap() {
        self.modalViewModel.didTap()
    }

    func didPanned(distance: Float, velocity: Float) {
        self.modalViewModel.panState.accept(.changed(lentgh: distance, velocity: velocity))
    }

    func didEndPanned(distance: Float, velocity: Float) {
        self.modalViewModel.panState.accept(.ended(length: distance, velocity: velocity))
        self.modalViewModel.panState.accept(.none)
    }

    func didTapMinimizeButton() {
        self.modalViewModel.modalState.accept(.mini)
    }
}
