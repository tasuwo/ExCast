//
//  EpisodeDetailViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class EpisodeDetailViewController: UIViewController {
    typealias Factory = ViewControllerFactory

    @IBOutlet var episodeDetailView: EpisodeDetailView!

    private let factory: Factory
    private let viewModel: EpisodeDetailViewModel

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(factory: Factory, viewModel: EpisodeDetailViewModel) {
        self.factory = factory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.title
            .bind(to: episodeDetailView.episodeTitleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.pubDate
            .map { d in d?.asFormattedString() ?? "" }
            .bind(to: episodeDetailView.episodePubDateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.duration
            .map { d in d.asTimeString() ?? "" }
            .bind(to: episodeDetailView.episodeDurationLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.thumbnail
            .compactMap { $0 }
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap { UIImage(data: $0) }
            .bind(to: episodeDetailView.episodeThumbnailView.rx.image)
            .disposed(by: disposeBag)

        let fontSize = episodeDetailView.episodeDescriptionLabel.font!.pointSize
        viewModel.description
            .observeOn(MainScheduler.instance)
            .compactMap { $0.dataForHtml(withFontSize: fontSize) }
            .observeOn(MainScheduler.instance)
            .compactMap { $0.makeHtmlString() }
            .bind(to: episodeDetailView.episodeDescriptionLabel.rx.attributedText)
            .disposed(by: disposeBag)
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
