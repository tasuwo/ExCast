//
//  EpisdoePlayerScrubSlider.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents

protocol EpisodePlayerSeekBarContainerDelegate: AnyObject {

    func didStartSeek()

    func didEndSeek()

    func didChangeSeekValue(to time: TimeInterval)

}

class EpisodePlayerSeekBarContainer: UIView {

    weak var delegate: EpisodePlayerSeekBarContainerDelegate!

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var bar: MDCSlider!

    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var remainingTimeLabel: UILabel!

    @IBAction func onTouchSeekBar(_ sender: Any) {
        self.delegate.didStartSeek()
    }

    @IBAction func onTouchUpInsideSeekbar(_ slider: MDCSlider) {
        // TODO: Disable seek by single tap.
        self.delegate.didChangeSeekValue(to: TimeInterval(slider.value))
        self.delegate.didEndSeek()
    }

    @IBAction func onTouchUpOutsideSeekbar(_ sender: Any) {
        self.delegate.didEndSeek()
    }

    @IBAction func onValueChangedSeekBar(_ slider: MDCSlider) {
        self.delegate.didChangeSeekValue(to: TimeInterval(slider.value))
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

        bundle.loadNibNamed("EpisodePlayerSeekBarContainer", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        self.backgroundColor = .clear
        self.baseView.backgroundColor = .clear

        self.bar.isStatefulAPIEnabled = true
        self.bar.setThumbColor(.gray, for: .normal)
        self.bar.setTrackFillColor(.gray, for: .normal)

        self.currentTimeLabel.text = "00:00"
        self.remainingTimeLabel.text = "-00:00"
    }

}
