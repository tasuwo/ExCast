//
//  EpisdoePlayerScrubSlider.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol EpisodePlayerSeekBarDelegate: AnyObject {

    func didGrabbedPlaybackSlider()

    func didReleasedPlaybackSlider()

    func didChangePlaybackSliderValue(to time: TimeInterval)

}

class EpisodePlayerSeekBar: UIView {

    weak var delegate: EpisodePlayerSeekBarDelegate!

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var scrubBar: UISlider!

    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var remainingTimeLabel: UILabel!

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

        bundle.loadNibNamed("EpisodePlayerSeekBar", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        self.backgroundColor = .clear
        self.baseView.backgroundColor = .clear

        self.currentTimeLabel.text = "00:00"
        self.remainingTimeLabel.text = "-00:00"
    }

}
