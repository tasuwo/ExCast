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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var episodeThumbnailView: UIImageView!
    @IBOutlet weak var episodePubDateLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeDurationLabel: UILabel!
    @IBOutlet weak var episodeDescriptionLabel: UITextView!

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

        bundle.loadNibNamed("EpisodeDetailView", owner: self, options: nil)

        // TODO: ここのサイズ調整がうまくいかないので、どうにかする。。。
        self.baseView.frame = UIScreen.main.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        // TODO: バグで Interface Builder 上での Dynamic Color が反映されていないのだと思われる。修正されたら外す
        if #available(iOS 13.0, *) {
            self.baseView.backgroundColor = UIColor.systemBackground
            self.contentView.backgroundColor = UIColor.systemBackground
            self.episodeDescriptionLabel.backgroundColor = UIColor.systemBackground
        }

        self.baseView.isScrollEnabled = true
        self.episodeThumbnailView.layer.cornerRadius = 10
        self.episodeDescriptionLabel.isEditable = false
        self.episodeDescriptionLabel.isSelectable = true
        self.episodeDescriptionLabel.isScrollEnabled = false
    }

}
