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

}

class EpisodePlayerModalView: UIView {

    weak var delegate: EpisodePlayerModalViewDelegate?

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var showTitleLabel: UILabel!

    @IBOutlet weak var episodeTitleLabel: UILabel!

    @IBOutlet weak var thumbnailImageView: UIImageView!

    @IBOutlet weak var controller: EpisodePlayerController!

    @IBOutlet weak var dismissButton: UIButton!

    @IBOutlet var playerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var playerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailTopConstraint: NSLayoutConstraint!
    @IBOutlet var thumbnailRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailLeftConstraint: NSLayoutConstraint!

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

        bundle.loadNibNamed("EpisodePlayerModalView", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        self.dismissButton.isHidden = true
        self.thumbnailImageView.layer.cornerRadius = 20
    }

}
