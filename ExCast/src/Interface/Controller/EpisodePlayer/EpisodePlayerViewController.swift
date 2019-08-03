//
//  EpisodePlayerViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol EpisodePlayerPresenterDelegate: AnyObject {
    func didDismissPlayer()
}

protocol EpisodePlayerPresenter: AnyObject {

    func playingEpisode() -> Podcast.Episode?

    func setDelegate(_ delegate: EpisodePlayerPresenterDelegate)

    func show(show: Podcast.Show, episode: Podcast.Episode)

    func dismiss()

    func minimize()

    func expand()

}

class EpisodePlayerViewController: UIViewController {

    @IBOutlet weak var modalView: EpisodePlayerModalView!

    private unowned var playerPresenter: EpisodePlayerPresenter

    var playingEpisode: Podcast.Episode {
        get {
            return self.informationViewModel.episode
        }
    }

    private var modalViewModel: EpisodePlayerModalViewModel!
    private var controllerViewModel: EpisodePlayerControllerViewModel!
    private var informationViewModel: EpisodePlayerInformationViewModel!

    // MARK: - Initializer

    init(presenter: EpisodePlayerPresenter,
         viewModel: EpisodePlayerControllerViewModel,
         informationViewModel: EpisodePlayerInformationViewModel,
         modalViewModel: EpisodePlayerModalViewModel) {
        self.playerPresenter = presenter
        self.controllerViewModel = viewModel
        self.informationViewModel = informationViewModel
        self.modalViewModel = modalViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate

        self.modalView.delegate = self
        self.modalView.seekBar.delegate = self
        self.modalView.playbackButtons.delegate = self

        // Bind

        self.modalViewModel.modalState ->> self.modalView.layoutBond
        self.bindEpisode()

        // Setup

        self.modalViewModel.setup()
    }

    // MARK: - Methods

    func reload(controllerViewModel: EpisodePlayerControllerViewModel,
                informationViewModel: EpisodePlayerInformationViewModel) {
        self.controllerViewModel = nil
        self.controllerViewModel = controllerViewModel
        self.informationViewModel = nil
        self.informationViewModel = informationViewModel

        self.bindEpisode()
    }

    private func bindEpisode() {
        let length = self.controllerViewModel.episode.episodeLength
        self.modalView.seekBar.bar.maximumValue = length

        // Bind

        self.informationViewModel.showTitle ->> self.modalView.showTitleLabel
        self.informationViewModel.episodeTitle ->> self.modalView.episodeTitleLabel
        self.informationViewModel.thumbnail ->> self.modalView.thumbnailImageView

        self.controllerViewModel.isPrepared ->> self.modalView.playbackButtons.playbackButton
        self.controllerViewModel.isPrepared ->> self.modalView.playbackButtons.forwardSkipButton
        self.controllerViewModel.isPrepared ->> self.modalView.playbackButtons.backwardSkipButton
        self.controllerViewModel.isPlaying ->> self.modalView.playbackButtons.playbackButtonBond
        self.controllerViewModel.displayCurrentTime.map { $0.asTimeString() ?? "" } ->> self.modalView.seekBar.currentTimeLabel
        self.controllerViewModel.displayCurrentTime.map { (Float($0) - length).asTimeString() ?? "" } ->> self.modalView.seekBar.remainingTimeLabel
        self.controllerViewModel.displayCurrentTime.map { Float($0) } ->> self.modalView.seekBar.bar

        // Setup

        self.informationViewModel.setup()
        self.controllerViewModel.setup()
    }

}

extension EpisodePlayerViewController: EpisodePlayerPlaybackButtonsDelegate {

    // MARK: EpisodePlayerPlaybackButtonsDelegate

    func didTapPlaybackButton() {
        self.controllerViewModel.playback()
    }

    func didTapSkipForwardButton() {
        self.controllerViewModel.skipForward()
    }

    func didTapSkipBackwardButton() {
        self.controllerViewModel.skipBackward()
    }

}

extension EpisodePlayerViewController: EpisodePlayerSeekBarContainerDelegate {

    func didStartSeek() {
        self.controllerViewModel.isSliderGrabbed.value = true
    }

    func didEndSeek() {
        self.controllerViewModel.isSliderGrabbed.value = false
    }

    func didChangeSeekValue(to time: TimeInterval) {
        self.controllerViewModel.displayCurrentTime.value = time
    }

}

extension EpisodePlayerViewController: EpisodePlayerModalViewDelegate {

    // MARK: - EpisodePlayerModalViewDelegate

    func shouldDismiss() {
        self.playerPresenter.dismiss()
    }

    func shouldMinimize() {
        self.playerPresenter.minimize()
    }

    func shouldExpand() {
        self.playerPresenter.expand()
    }

    func didTap() {
        self.modalViewModel.didTap()
    }

    func didPanned(distance: Float, velocity: Float) {
        self.modalViewModel.panState.value = .changed(lentgh: distance, velocity: velocity)
    }

    func didEndPanned(distance: Float, velocity: Float) {
        self.modalViewModel.panState.value = .ended(length: distance, velocity: velocity)
        self.modalViewModel.panState.value = .none
    }

    func didTapMinimizeButton() {
        self.modalViewModel.modalState.value = .mini
    }

}
