//
//  EpisodePlayer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents

protocol EpisodePlayerPlaybackButtonsDelegate: AnyObject {

    func didTapPlaybackButton()

    func didTapSkipForwardButton()

    func didTapSkipBackwardButton()

}

class EpisodePlayerPlaybackButtons: UIView {

    weak var delegate: EpisodePlayerPlaybackButtonsDelegate!
    
    @IBOutlet var baseView: UIView!

    @IBOutlet weak var playbackButton: MDCFloatingButton!

    @IBOutlet weak var forwardSkipButton: MDCFloatingButton!

    @IBOutlet weak var backwardSkipButton: MDCFloatingButton!

    @IBOutlet weak var playbackButtonSizeConstraint: NSLayoutConstraint!

    @IBOutlet weak var forwardSkipButtonSizeConstraint: NSLayoutConstraint!

    @IBOutlet weak var backwardSkipButtonSizeConstraint: NSLayoutConstraint!

    @IBOutlet weak var buttonMarginLeftConstraint: NSLayoutConstraint!

    @IBOutlet weak var buttonMarginRightConstraint: NSLayoutConstraint!

    @IBAction func didTapPlaybackButton(_ sender: Any) {
        self.delegate?.didTapPlaybackButton()
    }

    @IBAction func didTapSkipForwardButton(_ sender: Any) {
        self.delegate?.didTapSkipForwardButton()
    }

    @IBAction func didTapSkipBackwardButton(_ sender: Any) {
        self.delegate?.didTapSkipBackwardButton()
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

        bundle.loadNibNamed("EpisodePlayerPlaybackButtons", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        self.backgroundColor = .clear
        self.baseView.backgroundColor = .clear

        self.playbackButton.setImage(UIImage(named: "player_playback")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.playbackButton.imageEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        
        self.forwardSkipButton.setImage(UIImage(named: "player_skip_forward_15"), for: .normal)
        self.forwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        self.backwardSkipButton.setImage(UIImage(named: "player_skip_backward_15"), for: .normal)
        self.backwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

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
            self.playbackButton.setBackgroundColor(.black)
            self.forwardSkipButton.setBackgroundColor(.black)
            self.backwardSkipButton.setBackgroundColor(.black)
        }
    }

}
