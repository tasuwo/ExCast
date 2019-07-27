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

    func didTapView()

}

class EpisodePlayerModalView: UIView {

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var controller: EpisodePlayerController!

    @IBOutlet weak var toggleButton: UIButton!

    @IBAction func didTapToggleButton(_ sender: Any) {
        self.delegate?.didTapToggleButton()
    }

    @IBAction func didTapView(_ sender: Any) {
        self.delegate?.didTapView()
    }

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
