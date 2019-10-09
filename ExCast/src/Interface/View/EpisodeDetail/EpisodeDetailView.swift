//
//  EpisodeDetailView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import WebKit

class EpisodeDetailView: UIView {
    @IBOutlet var baseView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var episodeThumbnailView: UIImageView!
    @IBOutlet var episodePubDateLabel: UILabel!
    @IBOutlet var episodeTitleLabel: UILabel!
    @IBOutlet var episodeDurationLabel: UILabel!
    @IBOutlet var episodeDescriptionLabel: UITextView!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setupAppearences()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
        setupAppearences()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("EpisodeDetailView", owner: self, options: nil)

        // TODO: ここのサイズ調整がうまくいかないので、どうにかする。。。
        baseView.frame = UIScreen.main.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        baseView.isScrollEnabled = true
        episodeThumbnailView.layer.cornerRadius = 10
        episodeDescriptionLabel.isEditable = false
        episodeDescriptionLabel.isSelectable = true
        episodeDescriptionLabel.isScrollEnabled = false
    }
}
