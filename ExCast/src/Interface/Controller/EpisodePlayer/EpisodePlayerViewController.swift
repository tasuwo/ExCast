//
//  EpisodePlayerViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class EpisodePlayerViewController: UIViewController {

    @IBOutlet weak var modalView: EpisodePlayerModalView!

    private unowned var layoutController: EpisodePlayerModalLaytoutController
    private var modalViewModel: EpisodePlayerModalViewModel!
    private var playerViewModel: EpisodePlayerViewModel!

    // MARK: - Initializer

    init(layoutController: EpisodePlayerModalLaytoutController,
         playerViewModel: EpisodePlayerViewModel,
         modalViewModel: EpisodePlayerModalViewModel) {
        self.layoutController = layoutController
        self.playerViewModel = playerViewModel
        self.modalViewModel = modalViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.modalView.delegate = self
        self.modalView.seekBar.delegate = self
        self.modalView.playbackButtons.delegate = self

        // TODO: modal 関連処理は分離したい
        self.modalViewModel.modalState ->> self.modalView.layoutBond

        self.bindCurrentPlayerViewModelToView()

        self.modalViewModel.setup()
    }

    // MARK: - Methods

    func reload(by model: EpisodePlayerViewModel) {
        self.playerViewModel = nil
        self.playerViewModel = model

        self.bindCurrentPlayerViewModelToView()
    }

    private func bindCurrentPlayerViewModelToView() {
        // TODO:
        let duration = Double(self.playerViewModel.episode.duration!)
        self.modalView.seekBar.scrubBar.maximumValue = Float(duration)

        self.playerViewModel.showTitle ->> self.modalView.showTitleLabel
        self.playerViewModel.episodeTitle ->> self.modalView.episodeTitleLabel
        self.playerViewModel.thumbnail ->> self.modalView.thumbnailImageView
        self.playerViewModel.isPrepared ->> self.modalView.playbackButtons.playbackButton
        self.playerViewModel.isPrepared ->> self.modalView.playbackButtons.forwardSkipButton
        self.playerViewModel.isPrepared ->> self.modalView.playbackButtons.backwardSkipButton
        self.playerViewModel.isPlaying ->> self.modalView.playbackButtons.playbackButtonBond
        self.playerViewModel.displayCurrentTime.map { $0.asTimeString() ?? "" } ->> self.modalView.seekBar.currentTimeLabel
        self.playerViewModel.displayCurrentTime.map { ($0 - duration).asTimeString() ?? "" } ->> self.modalView.seekBar.remainingTimeLabel
        self.playerViewModel.displayCurrentTime.map { Float($0) } ->> self.modalView.seekBar.scrubBar

        self.playerViewModel.setup()
    }

}

extension EpisodePlayerViewController: EpisodePlayerPlaybackButtonsDelegate {

    // MARK: EpisodePlayerPlaybackButtonsDelegate

    func didTapPlaybackButton() {
        self.playerViewModel.playback()
    }

    func didTapSkipForwardButton() {
        self.playerViewModel.skipForward()
    }

    func didTapSkipBackwardButton() {
        self.playerViewModel.skipBackward()
    }

}

extension EpisodePlayerViewController: EpisodePlayerSeekBarDelegate {

    func didGrabbedPlaybackSlider() {
        self.playerViewModel.isSliderGrabbed.value = true
    }

    func didReleasedPlaybackSlider() {
        self.playerViewModel.isSliderGrabbed.value = false
    }

    func didChangePlaybackSliderValue(to time: TimeInterval) {
        self.playerViewModel.displayCurrentTime.value = time
    }

}

// TODO: Modal 関連処理は分離したい
extension EpisodePlayerViewController: EpisodePlayerModalViewDelegate {

    // MARK: - EpisodePlayerModalViewDelegate

    func shouldDismiss() {
        self.layoutController.dismiss()
    }

    func shouldMinimize() {
        self.layoutController.minimize()
    }

    func shouldExpand() {
        self.layoutController.expand()
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

}
