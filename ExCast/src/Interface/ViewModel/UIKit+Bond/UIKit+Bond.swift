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
                    self.playbackButton.setTitle("||", for: .normal)
                } else {
                    self.playbackButton.setTitle("▶︎", for: .normal)
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
    var layoutBond: Bond<EpisodePlayerModalViewModel.State> {
        if let bond = objc_getAssociatedObject(self, &episodePlayerModalLyaoutHandles) {
            return bond as! Bond<EpisodePlayerModalViewModel.State>
        } else {
            let bond = Bond<EpisodePlayerModalViewModel.State>() { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .fullscreen:
                    self.toggleButton.setTitle("Hide", for: .normal)
                    self.expand()
                case .mini:
                    self.toggleButton.setTitle("Expand", for: .normal)
                    self.minimize()
                case .hide:
                    self.delegate?.shouldDismiss()
                }
            }

            objc_setAssociatedObject(self, &episodePlayerModalLyaoutHandles, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}
