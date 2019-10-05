//
//  EpisodeDetailViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class EpisodeDetailViewController: UIViewController {

    @IBOutlet weak var episodeDetailView: EpisodeDetailView!
    private let viewModel: EpisodeDetailViewModel

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(viewModel: EpisodeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.title
            .bind(to: self.episodeDetailView.episodeTitleLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.viewModel.pubDate
            .map { d in d?.asFormattedString() ?? "" }
            .bind(to: self.episodeDetailView.episodePubDateLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.viewModel.duration
            .map { d in d.asTimeString() ?? "" }
            .bind(to: self.episodeDetailView.episodePubDateLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.viewModel.thumbnail
            .compactMap({ $0 })
            .compactMap({ try? Data(contentsOf: $0) })
            .compactMap({ UIImage(data: $0) })
            .bind(to: self.episodeDetailView.episodeThumbnailView.rx.image)
            .disposed(by: self.disposeBag)

        let fontSize = self.episodeDetailView.episodeDescriptionLabel.font!.pointSize
        self.viewModel.description
            .map({ String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize); color: \(UIColor.black.rgbString)\">%@</span>", $0) })
            .compactMap({ $0.data(using: .utf8) })
            .compactMap({
                try? NSAttributedString(
                    data: $0,
                    options: [
                        .documentType:NSAttributedString.DocumentType.html,
                        .characterEncoding:String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
                )
            })
            .bind(to: self.episodeDetailView.episodeDescriptionLabel.rx.attributedText)
            .disposed(by: self.disposeBag)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard let previousTraitCollection = previousTraitCollection else { return }

        if #available(iOS 13.0, *) {
            if previousTraitCollection.hasDifferentColorAppearance(comparedTo: self.traitCollection) {
                self.viewModel.layoutDescription()
            }
        }
    }

}
