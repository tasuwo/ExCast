//
//  EpisodePlayerViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class EpisodePlayerViewController: UIViewController {

    @IBOutlet weak var playerController: EpisodePlayerController!
    private var viewModel: EpisodePlayerViewModel

    // MARK: - Initializer

    init(viewModel: EpisodePlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.playerController.delegate = self
        
        // TODO:
        self.playerController.playbackSlidebar.maximumValue = Float(self.viewModel.episode.duration!)

        self.viewModel.isPrepared ->> self.playerController.playbackButton
        self.viewModel.isPrepared ->> self.playerController.forwardSkipButton
        self.viewModel.isPrepared ->> self.playerController.backwardSkipButton
        self.viewModel.displayCurrentTime.map { String($0) } ->> self.playerController.currentTimeLabel
        self.viewModel.displayCurrentTime.map { Float($0) } ->> self.playerController.playbackSlidebar

        self.viewModel.setup()
    }

}

extension EpisodePlayerViewController: EpisodePlayerControllerDelegate {

    // MARK: EpisodePlayerControllerDelegate

    func didTapPlaybackButton() {
        self.viewModel.playback()
    }

    func didTapSkipForwardButton() {
        self.viewModel.skipForward()
    }

    func didTapSkipBackwardButton() {
        self.viewModel.skipBackward()
    }

    func didGrabbedPlaybackSlider() {
        self.viewModel.isSliderGrabbed.value = true
    }

    func didReleasedPlaybackSlider() {
        self.viewModel.isSliderGrabbed.value = false
    }

    func didChangePlaybackSliderValue(to time: TimeInterval) {
        self.viewModel.displayCurrentTime.value = time
    }

}
