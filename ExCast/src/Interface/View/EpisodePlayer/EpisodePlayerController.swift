//
//  EpisodePlayer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol EpisodePlayerControllerDelegate {
    func didTapPlaybackButton()
    func didTapSkipForwardButton()
    func didTapSkipBackwardButton()
}

class EpisodePlayerController: UIView {
    
    @IBOutlet var baseView: UIView!

    @IBOutlet weak var playbackButton: UIButton!

    @IBOutlet weak var forwardSkipButton: UIButton!

    @IBOutlet weak var backwardSkipButton: UIButton!

    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBAction func didTapPlaybackButton(_ sender: Any) {
        self.delegate?.didTapPlaybackButton()
    }

    @IBAction func didTapSkipForwardButton(_ sender: Any) {
        self.delegate?.didTapSkipForwardButton()
    }

    @IBAction func didTapSkipBackwardButton(_ sender: Any) {
        self.delegate?.didTapSkipBackwardButton()
    }

    var delegate: EpisodePlayerControllerDelegate!

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

        bundle.loadNibNamed("EpisodePlayerController", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

}
