//
//  EpisodePlayerModalView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol EpisodePlayerModalViewDelegate: AnyObject {

    func shouldDismiss()

    func shouldMinimize()

    func shouldExpand()

    func didTap()

    func didPanned(distance: Float, velocity: Float)

    func didEndPanned(distance: Float, velocity: Float)

    func didTapMinimizeButton()

}

class EpisodePlayerModalView: UIView {

    weak var delegate: EpisodePlayerModalViewDelegate?

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var minimizeViewButton: UIButton!

    @IBOutlet weak var showTitleLabel: UILabel!

    @IBOutlet weak var episodeTitleLabel: UILabel!

    @IBOutlet weak var thumbnailImageView: UIImageView!

    @IBOutlet weak var seekBar: EpisodePlayerSeekBarContainer!

    @IBOutlet weak var playbackButtons: EpisodePlayerPlaybackButtons!

    @IBOutlet weak var dismissButton: UIButton!

    @IBOutlet var playbackButtonsHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var playbackButtonsBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var thumbnailTopConstraint: NSLayoutConstraint!

    @IBOutlet var thumbnailLeftConstraint: NSLayoutConstraint!

    @IBOutlet var thumbnailXConstraint: NSLayoutConstraint!

    @IBOutlet var thumbnailBottomConstraint: NSLayoutConstraint!

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!

    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!

    @IBAction func didTapDismissButton(_ sender: Any) {
        self.delegate?.shouldDismiss()
    }

    var lastYLocation: CGFloat = 0
    var distance: CGFloat = 0
    @IBAction func didPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }

        let translation = gestureRecognizer.translation(in: view.superview)
        let velocity = gestureRecognizer.velocity(in: view.superview)

        switch gestureRecognizer.state {
        case .began:
            self.distance = 0
            self.delegate?.didPanned(distance: Float(self.distance), velocity: Float(velocity.y))
            self.lastYLocation = 0
        case .changed:
            self.distance += translation.y - self.lastYLocation
            self.delegate?.didPanned(distance: Float(self.distance), velocity: Float(velocity.y))
            self.lastYLocation = translation.y
        case .ended:
            self.distance += translation.y - self.lastYLocation
            self.delegate?.didEndPanned(distance: Float(self.distance), velocity: Float(velocity.y))
            self.lastYLocation = 0
        case .possible, .cancelled, .failed:
            break
        @unknown default:
            break
        }
    }

    @IBAction func didTap(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            self.delegate?.didTap()
        default:
            break
        }
    }
    
    @IBAction func didTapMinimizeViewButton(_ sender: Any) {
        self.delegate?.didTapMinimizeButton()
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
        self.setupAppearences()
        self.setupGestureRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
        self.setupAppearences()
        self.setupGestureRecognizer()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("EpisodePlayerModalView", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        self.minimizeViewButton.setImage(UIImage(named: "player_down_arrow_black"), for: .normal)
        self.minimizeViewButton.tintColor = .black
        self.dismissButton.isHidden = true
        self.dismissButton.setImage(UIImage(named: "player_cancel_black"), for: .normal)
        self.dismissButton.tintColor = .black
        self.thumbnailImageView.layer.cornerRadius = 20
    }

    private func setupGestureRecognizer() {
        self.panGestureRecognizer.cancelsTouchesInView = false
        self.tapGestureRecognizer.cancelsTouchesInView = false
        self.panGestureRecognizer.delegate = self
        self.tapGestureRecognizer.delegate = self
    }

}

extension EpisodePlayerModalView: UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view is UIButton == false
    }

}
