//
//  EpisodePlayer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import UIKit

protocol EpisodePlayerPlaybackButtonsDelegate: AnyObject {
    func didTapPlaybackButton()

    func didTapSkipForwardButton()

    func didTapSkipBackwardButton()
}

public class EpisodePlayerPlaybackButtons: UIView {
    weak var delegate: EpisodePlayerPlaybackButtonsDelegate!

    public var isEnabled: Bool {
        set {
            playbackButton.isEnabled = newValue
            forwardSkipButton.isEnabled = newValue
            backwardSkipButton.isEnabled = newValue
        }
        get {
            // TODO:
            return false
        }
    }

    public var isPlaying: Bool {
        set {
            if newValue {
                self.playbackButton.setImage(UIImage(named: "player_pause"), for: .normal)
            } else {
                self.playbackButton.setImage(UIImage(named: "player_playback"), for: .normal)
            }
        }
        get {
            // TODO:
            return false
        }
    }

    // MARK: - IBOutlets

    @IBOutlet var baseView: UIView!
    @IBOutlet var playbackButton: MDCFloatingButton!
    @IBOutlet var forwardSkipButton: MDCFloatingButton!
    @IBOutlet var backwardSkipButton: MDCFloatingButton!
    @IBOutlet var playbackButtonSizeConstraint: NSLayoutConstraint!
    @IBOutlet var forwardSkipButtonSizeConstraint: NSLayoutConstraint!
    @IBOutlet var backwardSkipButtonSizeConstraint: NSLayoutConstraint!
    @IBOutlet var buttonMarginLeftConstraint: NSLayoutConstraint!
    @IBOutlet var buttonMarginRightConstraint: NSLayoutConstraint!

    // MARK: - IBActions

    @IBAction func didTapPlaybackButton(_: Any) {
        delegate?.didTapPlaybackButton()
    }

    @IBAction func didTapSkipForwardButton(_: Any) {
        delegate?.didTapSkipForwardButton()
    }

    @IBAction func didTapSkipBackwardButton(_: Any) {
        delegate?.didTapSkipBackwardButton()
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

        bundle.loadNibNamed("EpisodePlayerPlaybackButtons", owner: self, options: nil)

        baseView.frame = bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        backgroundColor = .clear
        baseView.backgroundColor = .clear

        playbackButton.setImage(UIImage(named: "player_playback")?.withRenderingMode(.alwaysTemplate), for: .normal)
        playbackButton.imageEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)

        forwardSkipButton.setImage(UIImage(named: "player_skip_forward_15"), for: .normal)
        forwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        backwardSkipButton.setImage(UIImage(named: "player_skip_backward_15"), for: .normal)
        backwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        if #available(iOS 13.0, *) {
            let buttonColor = UIColor { (trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return .lightGray
                } else {
                    return .black
                }
            }

            self.playbackButton.setBackgroundColor(buttonColor)
            self.forwardSkipButton.setBackgroundColor(buttonColor)
            self.backwardSkipButton.setBackgroundColor(buttonColor)
        } else {
            playbackButton.setBackgroundColor(.black)
            forwardSkipButton.setBackgroundColor(.black)
            backwardSkipButton.setBackgroundColor(.black)
        }
    }
}
