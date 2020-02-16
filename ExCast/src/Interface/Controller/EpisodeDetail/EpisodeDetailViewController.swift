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
    typealias Dependency = EpisodeDetailViewModelType

    @IBOutlet var episodeDetailView: EpisodeDetailView!

    private let factory: Factory
    private let viewModel: EpisodeDetailViewModelType

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(factory: Factory, viewModel: EpisodeDetailViewModelType) {
        self.factory = factory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind(to: self.viewModel)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard let previousTraitCollection = previousTraitCollection else { return }

        if #available(iOS 13.0, *) {
            if previousTraitCollection.hasDifferentColorAppearance(comparedTo: self.traitCollection) {
                self.viewModel.inputs.layoutDescription()
            }
        }
    }
}

extension EpisodeDetailViewController {
    // MARK: - Binding

    func bind(to dependency: Dependency) {
        dependency.outputs.title
            .drive(self.episodeDetailView.rx.title)
            .disposed(by: self.disposeBag)
        dependency.outputs.pubDate
            .drive(self.episodeDetailView.rx.publishDate)
            .disposed(by: self.disposeBag)
        dependency.outputs.duration
            .drive(self.episodeDetailView.rx.duration)
            .disposed(by: self.disposeBag)
        dependency.outputs.thumbnail
            .drive(onNext: { thumbnail in
                guard let thumbnail = thumbnail,
                    let data = try? Data(contentsOf: thumbnail),
                    let image = UIImage(data: data) else { return }
                self.episodeDetailView.thumbnail = image
            })
            .disposed(by: self.disposeBag)
        dependency.outputs.description
            .drive(episodeDetailView.rx.episodeDescripiton)
            .disposed(by: self.disposeBag)
    }
}
