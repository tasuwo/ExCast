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

public class EpisodePlayerModalView: UIView {
    weak var delegate: EpisodePlayerModalViewDelegate?

    public var showTitle: String {
        set {
            showTitleLabel.text = newValue
        }
        get {
            return showTitleLabel.text ?? ""
        }
    }

    public var episodeTitle: String {
        set {
            episodeTitleLabel.text = newValue
        }
        get {
            return episodeTitleLabel.text ?? ""
        }
    }

    public var thumbnail: UIImage? {
        set {
            thumbnailImageView.image = newValue
        }
        get {
            return thumbnailImageView.image
        }
    }

    public var duration: Double {
        set {
            seekBar.duration = newValue
        }
        get {
            return seekBar.duration
        }
    }

    public var currentTime: Double {
        set {
            seekBar.currentTime = newValue
        }
        get {
            return seekBar.currentTime
        }
    }

    public var isPlaybackEnabled: Bool {
        set {
            playbackButtons.isEnabled = newValue
        }
        get {
            return playbackButtons.isEnabled
        }
    }

    public var isPlaying: Bool {
        set {
            self.playbackButtons.isPlaying = newValue
        }
        get {
            return self.playbackButtons.isPlaying
        }
    }

    // MARK: - IBOutlets

    @IBOutlet var baseView: UIView!

    @IBOutlet var showTitleLabel: UILabel!
    @IBOutlet var episodeTitleLabel: UILabel!

    @IBOutlet var thumbnailImageView: UIImageView!

    @IBOutlet var seekBar: EpisodePlayerSeekBarContainer!

    @IBOutlet var playbackButtons: EpisodePlayerPlaybackButtons!
    @IBOutlet var minimizeViewButton: UIButton!
    @IBOutlet var dismissButton: UIButton!

    // MARK: Constraints

    @IBOutlet var playbackButtonsHeightConstraint: NSLayoutConstraint!
    @IBOutlet var playbackButtonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet var thumbnailTopConstraint: NSLayoutConstraint!
    @IBOutlet var thumbnailLeftConstraint: NSLayoutConstraint!
    @IBOutlet var thumbnailXConstraint: NSLayoutConstraint!
    @IBOutlet var thumbnailBottomConstraint: NSLayoutConstraint!

    // MARK: Gesture Recognizers

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!

    // MARK: - IBActions

    @IBAction func didTapDismissButton(_: Any) {
        delegate?.shouldDismiss()
    }

    var lastYLocation: CGFloat = 0
    var distance: CGFloat = 0
    @IBAction func didPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }

        let translation = gestureRecognizer.translation(in: view.superview)
        let velocity = gestureRecognizer.velocity(in: view.superview)

        switch gestureRecognizer.state {
        case .began:
            distance = 0
            delegate?.didPanned(distance: Float(distance), velocity: Float(velocity.y))
            lastYLocation = 0
        case .changed:
            distance += translation.y - lastYLocation
            delegate?.didPanned(distance: Float(distance), velocity: Float(velocity.y))
            lastYLocation = translation.y
        case .ended:
            distance += translation.y - lastYLocation
            delegate?.didEndPanned(distance: Float(distance), velocity: Float(velocity.y))
            lastYLocation = 0
        case .possible, .cancelled, .failed:
            break
        @unknown default:
            break
        }
    }

    @IBAction func didTap(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            delegate?.didTap()
        default:
            break
        }
    }

    @IBAction func didTapMinimizeViewButton(_: Any) {
        delegate?.didTapMinimizeButton()
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setupAppearences()
        setupGestureRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
        setupAppearences()
        setupGestureRecognizer()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("EpisodePlayerModalView", owner: self, options: nil)

        baseView.frame = bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        minimizeViewButton.setImage(UIImage(named: "player_down_arrow"), for: .normal)
        if #available(iOS 13.0, *) {
            self.minimizeViewButton.tintColor = .label
        } else {
            minimizeViewButton.tintColor = .black
        }

        dismissButton.isHidden = true
        dismissButton.setImage(UIImage(named: "player_cancel"), for: .normal)
        if #available(iOS 13.0, *) {
            self.dismissButton.tintColor = .label
        } else {
            dismissButton.tintColor = .black
        }

        thumbnailImageView.layer.cornerRadius = 20
    }

    private func setupGestureRecognizer() {
        panGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self
        tapGestureRecognizer.delegate = self
    }
}

extension EpisodePlayerModalView: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view is UIButton == false
    }
}

extension EpisodePlayerModalView {
    func minimize() {
        // SeekBar
        seekBar.isHidden = true
        playbackButtons.layoutIfNeeded()

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

    func expand() {
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
