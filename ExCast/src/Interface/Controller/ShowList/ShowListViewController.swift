//
//  TimeLineViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Domain
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class ShowListViewController: UIViewController {
    typealias Factory = ViewControllerFactory
    typealias Dependency = ShowListViewModelType

    @IBOutlet var showListView: ShowListView!
    private let dataSourceContainer = ShowListViewDataSourceContainer()

    private let factory: Factory
    private let viewModel: ShowListViewModelType

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(factory: Factory, viewModel: ShowListViewModelType) {
        self.factory = factory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        self.bind(to: self.viewModel)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        self.viewModel.inputs.podcastsLoaded.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = NSLocalizedString("ShowListView.title", comment: "")

        if let selectedRow = self.showListView.indexPathForSelectedRow {
            showListView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Methods

    private func setupNavigationBar() {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapTabBar))
        navigationItem.setRightBarButton(item, animated: true)
    }

    @objc private func didTapTabBar() {
        guard let navigationController = self.navigationController else { return }

        let nextViewController = factory.makeFeedUrlInputViewController()
        navigationController.pushViewController(nextViewController, animated: true)
    }

    private func presentEpisodes(of podcast: Podcast) {
        guard let navigationController = self.navigationController else { return }

        let nextViewController = factory.makeEpisodeListViewController(id: podcast.identity, show: podcast.meta)
        navigationController.pushViewController(nextViewController, animated: true)
    }
}

extension ShowListViewController {
    // MARK: - Binding

    func bind(to dependency: Dependency) {
        // MARK: Outputs

        dependency.outputs.podcasts
            .skip(1)
            .drive(self.showListView.rx.items(dataSource: self.dataSourceContainer.dataSource))
            .disposed(by: self.disposeBag)

        dependency.outputs.episodesViewPresented
            .emit(onNext: { [weak self] podcast in
                self?.presentEpisodes(of: podcast)
            })
            .disposed(by: self.disposeBag)

        // MARK: Inputs

        self.showListView.rx.itemDeleted.asSignal()
            .emit(to: dependency.inputs.podcastDeleted)
            .disposed(by: self.disposeBag)

        self.showListView.rx.itemSelected.asSignal()
            .emit(to: dependency.inputs.podcastSelected)
            .disposed(by: self.disposeBag)
    }
}
