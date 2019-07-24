//
//  EpisodePlayer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents

protocol EpisodePlayerControllerDelegate {
    func didTapPlaybackButton()
    func didTapSkipForwardButton()
    func didTapSkipBackwardButton()

    func didGrabbedPlaybackSlider()
    func didReleasedPlaybackSlider()

    func didChangePlaybackSliderValue(to time: TimeInterval)
}

class EpisodePlayerController: UIView {
    
    @IBOutlet var baseView: UIView!

    @IBOutlet weak var playbackSlidebar: UISlider!

    @IBOutlet weak var playbackButton: MDCFloatingButton!

    @IBOutlet weak var forwardSkipButton: MDCFloatingButton!

    @IBOutlet weak var backwardSkipButton: MDCFloatingButton!

    @IBOutlet weak var currentTimeLabel: UILabel!

    @IBAction func didTapPlaybackButton(_ sender: Any) {
        self.delegate?.didTapPlaybackButton()
    }

    @IBAction func didTapSkipForwardButton(_ sender: Any) {
        self.delegate?.didTapSkipForwardButton()
    }

    @IBAction func didTapSkipBackwardButton(_ sender: Any) {
        self.delegate?.didTapSkipBackwardButton()
    }

    @IBAction func onPlaybackTimeDidChage(_ sender: Any, forEvent event: UIEvent) {
        guard let slider = sender as? UISlider else { return }
        guard let touches = event.allTouches else { return }

        for touch in touches {
            switch (touch.phase) {
            case .began:
                self.delegate.didGrabbedPlaybackSlider()
            case .moved:
                self.delegate.didChangePlaybackSliderValue(to: TimeInterval(slider.value))
                break
            case .ended:
                self.delegate.didReleasedPlaybackSlider()
            default:
                break
            }

        }
    }

    var delegate: EpisodePlayerControllerDelegate!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
        self.setupAppearences()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
        self.setupAppearences()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("EpisodePlayerController", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        self.playbackButton.setTitle("▶︎", for: .normal)
        self.playbackButton.setTitleColor(.white, for: .normal)
        self.playbackButton.setBackgroundColor(.black)

        self.forwardSkipButton.setTitle("↪︎", for: .normal)
        self.forwardSkipButton.setTitleColor(.white, for: .normal)
        self.forwardSkipButton.setBackgroundColor(.black)

        self.backwardSkipButton.setTitle("↩︎", for: .normal)
        self.backwardSkipButton.setTitleColor(.white, for: .normal)
        self.backwardSkipButton.setBackgroundColor(.black)
    }

}
