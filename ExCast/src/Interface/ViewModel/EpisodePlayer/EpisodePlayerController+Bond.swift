//
//  EpisodePlayerController+Bond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import UIKit

private var episodePlayerModalLyaoutHandles: UInt8 = 0;

// MARK: EpisodePlayerController

private var playerPlaybackButtonHandles: UInt8 = 0;

extension EpisodePlayerPlaybackButtons {
    var playbackButtonBond: Bond<Bool> {
        if let bond = objc_getAssociatedObject(self, &playerPlaybackButtonHandles) {
            return bond as! Bond<Bool>
        } else {
            let bond = Bond<Bool>() { [weak self] isPlaying in
                guard let self = self else { return }

                if isPlaying {
                    self.playbackButton.setImage(UIImage(named: "player_pause"), for: .normal)
                } else {
                    self.playbackButton.setImage(UIImage(named: "player_playback"), for: .normal)
                }
            }

            objc_setAssociatedObject(self, &playerPlaybackButtonHandles, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension EpisodePlayerModalView {
    var layoutBond: Bond<EpisodePlayerModalViewModel.ModalState> {
        if let bond = objc_getAssociatedObject(self, &episodePlayerModalLyaoutHandles) {
            return bond as! Bond<EpisodePlayerModalViewModel.ModalState>
        } else {
            let bond = Bond<EpisodePlayerModalViewModel.ModalState>() { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .fullscreen:
                    self.expand()
                case .mini:
                    self.minimize()
                case .hide:
                    self.delegate?.shouldDismiss()
                default:
                    break
                }
            }

            objc_setAssociatedObject(self, &episodePlayerModalLyaoutHandles, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }

    private func minimize() {
        // SeekBar
        self.seekBar.isHidden = true
        self.playbackButtons.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            // Playback Buttons
            self.playbackButtons.buttonMarginLeftConstraint.constant = 36
            self.playbackButtons.buttonMarginRightConstraint.constant = 36
            self.playbackButtons.playbackButtonSizeConstraint.constant = 42
            self.playbackButtons.playbackButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.playbackButtons.forwardSkipButtonSizeConstraint.constant = 42
            self.playbackButtons.forwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            self.playbackButtons.backwardSkipButtonSizeConstraint.constant = 42
            self.playbackButtons.backwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            self.playbackButtonsHeightConstraint.constant = 70
            self.playbackButtonsBottomConstraint.constant = 0
            self.playbackButtons.layoutIfNeeded()

            // Header
            self.minimizeViewButton.isHidden = true
            self.showTitleLabel.isHidden = true
            self.episodeTitleLabel.isHidden = true

            // Thumbnail
            self.thumbnailImageView.layer.cornerRadius = 0
            self.thumbnailTopConstraint.constant = 0
            self.thumbnailLeftConstraint.isActive = false
            self.thumbnailXConstraint.isActive = false
            self.thumbnailBottomConstraint.isActive = false

            // Dismiss Button
            self.dismissButton.isHidden = false

            self.layoutIfNeeded()

            self.delegate?.shouldMinimize()
        }) { _ in
            if #available(iOS 13.0, *) {
                self.traitCollection.performAsCurrent {
                    self.baseView.backgroundColor = .secondarySystemBackground
                }
            } else {
                self.baseView.backgroundColor = .lightText
            }
        }
    }

    private func expand() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            // Playback Buttons
            self.playbackButtons.buttonMarginLeftConstraint.constant = 24
            self.playbackButtons.buttonMarginRightConstraint.constant = 24
            self.playbackButtons.playbackButtonSizeConstraint.constant = 72
            self.playbackButtons.playbackButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            self.playbackButtons.forwardSkipButtonSizeConstraint.constant = 60
            self.playbackButtons.forwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            self.playbackButtons.backwardSkipButtonSizeConstraint.constant = 60
            self.playbackButtons.backwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            self.playbackButtonsHeightConstraint.constant = 180
            self.playbackButtonsBottomConstraint.constant = 60
            self.playbackButtons.layoutIfNeeded()

            // Thumbnail
            self.thumbnailImageView.layer.cornerRadius = 20
            self.thumbnailTopConstraint.constant = 100
            self.thumbnailLeftConstraint.isActive = true
            self.thumbnailXConstraint.isActive = true
            self.thumbnailBottomConstraint.isActive = true

            // Dismiss Button
            self.dismissButton.isHidden = true

            self.layoutIfNeeded()

            self.delegate?.shouldExpand()
        }) { _ in
            // SeekBar
            self.seekBar.isHidden = false
            self.playbackButtons.layoutIfNeeded()

            // Header
            self.minimizeViewButton.isHidden = false
            self.showTitleLabel.isHidden = false
            self.episodeTitleLabel.isHidden = false

            self.layoutIfNeeded()
        }
    }
}
