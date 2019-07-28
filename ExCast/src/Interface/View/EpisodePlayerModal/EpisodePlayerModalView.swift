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

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var controller: EpisodePlayerController!

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

    @IBOutlet var dismissButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerHeightConstraint: NSLayoutConstraint!

    weak var delegate: EpisodePlayerModalViewDelegate?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("EpisodePlayerModalView", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

}
