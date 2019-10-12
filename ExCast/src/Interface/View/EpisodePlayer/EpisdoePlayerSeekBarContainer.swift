//
//  EpisdoePlayerScrubSlider.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import UIKit

protocol EpisodePlayerSeekBarContainerDelegate: AnyObject {
    func didStartSeek()

    func didEndSeek()

    func didChangeSeekValue(to time: TimeInterval)
}

class EpisodePlayerSeekBarContainer: UIView {
    weak var delegate: EpisodePlayerSeekBarContainerDelegate!

    public var duration: Double {
        set {
            bar.maximumValue = CGFloat(newValue)
            remainingTimeLabel.text = (currentTime - newValue).asTimeString()
        }
        get {
            return Double(bar.maximumValue)
        }
    }

    public var currentTime: Double {
        set {
            bar.value = CGFloat(newValue)
            currentTimeLabel.text = newValue.asTimeString()
            remainingTimeLabel.text = (newValue - duration).asTimeString()
        }
        get {
            // TODO:
            return 0
        }
    }

    // MARK: - IBOutlets

    @IBOutlet var baseView: UIView!
    @IBOutlet var bar: MDCSlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var remainingTimeLabel: UILabel!

    // MARK: - IBActions

    @IBAction func onTouchSeekBar(_: Any) {
        delegate.didStartSeek()
    }

    @IBAction func onTouchUpInsideSeekbar(_ slider: MDCSlider) {
        // TODO: Disable seek by single tap.
        delegate.didChangeSeekValue(to: TimeInterval(slider.value))
        delegate.didEndSeek()
    }

    @IBAction func onTouchUpOutsideSeekbar(_: Any) {
        delegate.didEndSeek()
    }

    @IBAction func onValueChangedSeekBar(_ slider: MDCSlider) {
        delegate.didChangeSeekValue(to: TimeInterval(slider.value))
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setupAppearences()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
        setupAppearences()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("EpisodePlayerSeekBarContainer", owner: self, options: nil)

        baseView.frame = bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        backgroundColor = .clear
        baseView.backgroundColor = .clear

        bar.isStatefulAPIEnabled = true
        bar.setThumbColor(.gray, for: .normal)
        bar.setTrackFillColor(.gray, for: .normal)

        currentTimeLabel.text = "00:00"
        remainingTimeLabel.text = "-00:00"
    }
}
