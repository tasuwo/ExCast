//
//  UILabel+Bond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import ObjectiveC

private var handle: UInt8 = 0;

// MARK: - UILabel

extension UILabel {
    var textBond: Bond<String> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<String>
        } else {
            let bond = Bond<String>() { [unowned self] value in self.text = value }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UILabel: Bondable {
    var designatedBond: Bond<String> {
        return self.textBond
    }
}

// MARK: - UITextField

extension UITextField {
    var textBond: Bond<String> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<String>
        } else {
            let bond = Bond<String>() { [unowned self] value in self.text = value }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UITextField: Bondable {
    var designatedBond: Bond<String> {
        return self.textBond
    }
}

// MARK: - UIButton

extension UIButton {
    var enableBond: Bond<Bool> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<Bool>
        } else {
            let bond = Bond<Bool>() { [unowned self] value in self.isEnabled = value }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UIButton: Bondable {
    var designatedBond: Bond<Bool> {
        return self.enableBond
    }
}

// MARK: - UIImageView

extension UIImageView {
    var imageBond: Bond<URL?> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<URL?>
        } else {
            let bond = Bond<URL?>() { [unowned self] url in
                guard let url = url else { return }

                DispatchQueue.global(qos: .background).async {
                    guard let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UIImageView: Bondable {
    var designatedBond: Bond<URL?> {
        return self.imageBond
    }
}

// MARK: - UITableView

protocol BondableTableView: AnyObject {
    associatedtype ContentType
    var contents: Array<ContentType> { get set }
}

extension BondableTableView where Self: UITableView {
    var contentsBond: ArrayBond<ContentType> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! ArrayBond<ContentType>
        }

        let bond = ArrayBond<ContentType>(insert: { [unowned self] tuples in
            DispatchQueue.main.async { [unowned self] in
                tuples.forEach { [unowned self] tuple in
                    self.contents.insert(tuple.1, at: tuple.0)
                }
                let indexPathes = tuples.map { IndexPath(item: $0.0, section: 0) }

                if tuples.count == 1 {
                    self.beginUpdates()
                    self.insertRows(at: indexPathes, with: .automatic)
                    self.endUpdates()
                }

                self.reloadData()
            }
        }, remove: { [unowned self] tuples in
            DispatchQueue.main.async { [unowned self] in
                tuples.forEach { [unowned self] tuple in self.contents.remove(at: tuple.0) }
                let indexPathes = tuples.map { IndexPath(item: $0.0, section: 0) }

                if tuples.count == 1 {
                    self.beginUpdates()
                    self.deleteRows(at: indexPathes, with: .automatic)
                    self.endUpdates()
                }
            }
        }, update: { [unowned self] tuples in
            DispatchQueue.main.async { [unowned self] in
                tuples.forEach { [unowned self] tuple in self.contents[tuple.0] = tuple.1 }
                self.reloadData()
            }
        })
        objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return bond
    }
}

// MARK: UISlider

private var sliderValueHandle: UInt8 = 0;

extension UISlider {
    var valueBond: Bond<Float> {
        if let bond = objc_getAssociatedObject(self, &sliderValueHandle) {
            return bond as! Bond<Float>
        } else {
            let bond = Bond<Float>() { [unowned self] value in self.value = value }
            objc_setAssociatedObject(self, &sliderValueHandle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UISlider: Bondable {
    var designatedBond: Bond<Float> {
        return self.valueBond
    }
}

// MARK: EpisodePlayerController

private var playerPlaybackButtonHandles: UInt8 = 0;

extension EpisodePlayerController {
    var playbackButtonBond: Bond<Bool> {
        if let bond = objc_getAssociatedObject(self, &playerPlaybackButtonHandles) {
            return bond as! Bond<Bool>
        } else {
            let bond = Bond<Bool>() { [weak self] isPlaying in
                guard let self = self else { return }

                if isPlaying {
                    self.playbackButton.setImage(UIImage(named: "player_pause_white"), for: .normal)
                } else {
                    self.playbackButton.setImage(UIImage(named: "player_playback_white"), for: .normal)
                }
            }

            objc_setAssociatedObject(self, &playerPlaybackButtonHandles, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

// MARK: EpisodePlayerModalView

private var episodePlayerModalLyaoutHandles: UInt8 = 0;

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
        self.controller.playbackSlidebar.isHidden = true
        self.controller.currentTimeLabel.isHidden = true
        self.controller.remainingTimeLabel.isHidden = true
        self.controller.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.controller.playbackButtonBottomConstraint.isActive = false
            self.controller.leftButtonMarginConstraint.constant = 36
            self.controller.rightButtonMarginConstraint.constant = 36
            self.controller.controlButtonSizeConstraint.constant = 42
            self.controller.playbackButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.controller.forwardSkipButtonSizeConstraint.constant = 42
            self.controller.forwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            self.controller.backwardSkipButtonSizeConstraint.constant = 42
            self.controller.backwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            self.controller.layoutIfNeeded()

            self.hidableMark.isHidden = true
            self.dismissButton.isHidden = false
            self.showTitleLabel.isHidden = true
            self.episodeTitleLabel.isHidden = true

            self.thumbnailImageView.layer.cornerRadius = 0
            self.thumbnailTopConstraint.constant = 0
            self.thumbnailLeftConstraint.isActive = false
            self.thumbnailXConstraint.isActive = false

            self.playerHeightConstraint.constant = 50
            self.playerBottomConstraint.isActive = false

            self.controllerTopConstraint.isActive = false

            self.layoutIfNeeded()

            self.baseView.layer.borderWidth = 1
            self.baseView.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
            self.baseView.layer.layoutIfNeeded()

            self.delegate?.shouldMinimize()
        }) { _ in
            self.baseView.backgroundColor = .lightText
        }
    }

    private func expand() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.controller.playbackButtonBottomConstraint.isActive = true
            self.controller.leftButtonMarginConstraint.constant = 24
            self.controller.rightButtonMarginConstraint.constant = 24
            self.controller.controlButtonSizeConstraint.constant = 72
            self.controller.playbackButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            self.controller.forwardSkipButtonSizeConstraint.constant = 60
            self.controller.forwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            self.controller.backwardSkipButtonSizeConstraint.constant = 60
            self.controller.backwardSkipButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            self.controller.layoutIfNeeded()

            self.dismissButton.isHidden = true
            self.thumbnailImageView.layer.cornerRadius = 20
            self.thumbnailTopConstraint.constant = 100
            self.thumbnailLeftConstraint.isActive = true
            self.thumbnailXConstraint.isActive = true
            self.playerHeightConstraint.constant = 180
            self.playerBottomConstraint.isActive = true
            self.controllerTopConstraint.isActive = true
            self.layoutIfNeeded()

            self.delegate?.shouldExpand()
        }) { _ in
            self.controller.playbackSlidebar.isHidden = false
            self.controller.currentTimeLabel.isHidden = false
            self.controller.remainingTimeLabel.isHidden = false
            self.controller.layoutIfNeeded()

            self.hidableMark.isHidden = false
            self.showTitleLabel.isHidden = false
            self.episodeTitleLabel.isHidden = false
            self.layoutIfNeeded()

            self.baseView.layer.borderWidth = 0
            self.baseView.layer.borderColor = nil
            self.baseView.layer.layoutIfNeeded()
        }
    }
}
