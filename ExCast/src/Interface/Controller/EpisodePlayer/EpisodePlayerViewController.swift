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
        self.modalView.controller.delegate = self

        // TODO: modal 関連処理は分離したい
        self.modalViewModel.state ->> self.modalView.layoutBond

        // TODO:
        self.modalView.controller.playbackSlidebar.maximumValue = Float(self.playerViewModel.episode.duration!)

        self.playerViewModel.isPrepared ->> self.modalView.controller.playbackButton
        self.playerViewModel.isPrepared ->> self.modalView.controller.forwardSkipButton
        self.playerViewModel.isPrepared ->> self.modalView.controller.backwardSkipButton
        self.playerViewModel.displayCurrentTime.map { String($0) } ->> self.modalView.controller.currentTimeLabel
        self.playerViewModel.displayCurrentTime.map { Float($0) } ->> self.modalView.controller.playbackSlidebar

        self.playerViewModel.setup()
    }

}

extension EpisodePlayerViewController: EpisodePlayerControllerDelegate {

    // MARK: EpisodePlayerControllerDelegate

    func didTapPlaybackButton() {
        self.playerViewModel.playback()
    }

    func didTapSkipForwardButton() {
        self.playerViewModel.skipForward()
    }

    func didTapSkipBackwardButton() {
        self.playerViewModel.skipBackward()
    }

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

    func didTapToggleButton() {
        self.modalViewModel.toggle()
    }

    func shouldDismiss() {
        self.layoutController.dismiss()
    }

    func shouldMinimize() {
        self.layoutController.minimize()
    }

    func shouldExpand() {
        self.layoutController.expand()
    }

}
