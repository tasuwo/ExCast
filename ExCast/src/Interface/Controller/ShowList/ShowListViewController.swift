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

    @IBOutlet var showListView: ShowListView!
    private let dataSourceContainer = ShowListViewDataSourceContainer()

    private let factory: Factory
    private let viewModel: ShowListViewModel

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(factory: Factory, viewModel: ShowListViewModel) {
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

        setupNavigationBar()

        viewModel.podcasts
            .flatMap { query -> Single<[AnimatableSectionModel<String, Podcast>]> in
                switch query {
                case let .contents(container):
                    debugLog("The show list is updated.")
                    return .just(container)
                default:
                    return .never()
                }
            }
            .bind(to: showListView.rx.items(dataSource: dataSourceContainer.dataSource))
            .disposed(by: disposeBag)

        showListView.rx.itemDeleted
            .map { $0.row }
            .bind(onNext: viewModel.remove(at:))
            .disposed(by: disposeBag)
        showListView.rx.itemSelected
            .bind(onNext: didSelectShow(at:))
            .disposed(by: disposeBag)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        viewModel.load()
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

    private func didSelectShow(at indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }

        let podcast = viewModel.podcastsCache.value(at: indexPath)
        let nextViewController = factory.makeEpisodeListViewController(id: podcast.identity, show: podcast.meta)
        navigationController.pushViewController(nextViewController, animated: true)
    }
}
