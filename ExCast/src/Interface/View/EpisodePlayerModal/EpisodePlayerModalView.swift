//
//  EpisodePlayerModalView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol EpisodePlayerModalViewDelegate: AnyObject {

    func didTapToggleButton()

    func shouldDismiss()

    func shouldMinimize()

    func shouldExpand()

}

class EpisodePlayerModalView: UIView {

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var controller: EpisodePlayerController!

    @IBOutlet weak var toggleButton: UIButton!

    @IBAction func didTapToggleButton(_ sender: Any) {
        self.delegate?.didTapToggleButton()
    }

    @IBAction func didTapDismissButton(_ sender: Any) {
        self.delegate?.shouldDismiss()
    }

    @IBOutlet var toggleButtonTopConstraint: NSLayoutConstraint!
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

    func minimize() {
        self.controller.minimize()
        self.playerHeightConstraint.constant = 50
        self.toggleButtonTopConstraint.isActive = false
        self.baseView.backgroundColor = .lightGray
        self.delegate?.shouldMinimize()
    }

    func expand() {
        self.controller.expand()
        self.playerHeightConstraint.constant = 180
        self.toggleButtonTopConstraint.isActive = true
        self.baseView.backgroundColor = .white
        self.delegate?.shouldExpand()
    }

}
