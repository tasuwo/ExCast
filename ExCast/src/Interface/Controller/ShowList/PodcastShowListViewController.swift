//
//  TimeLineViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class PodcastShowListViewController: UIViewController {
    @IBOutlet var showListView: PodcastShowListView!
    private let dataSourceContainer = PodcastShowListViewDataSourceContainer()

    private unowned let playerPresenter: EpisodePlayerPresenter
    private let viewModel: ShowListViewModel

    private let service: PodcastServiceProtocol
    private let gateway: PodcastGatewayProtocol

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(playerPresenter: EpisodePlayerPresenter,
         viewModel: ShowListViewModel,
         service: PodcastServiceProtocol,
         gateway: PodcastGatewayProtocol) {
        self.playerPresenter = playerPresenter
        self.viewModel = viewModel

        self.service = service
        self.gateway = gateway

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

        title = NSLocalizedString("PodcastShowListView.title", comment: "")

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
        guard let navC = self.navigationController else { return }
        let viewModel = FeedUrlInputViewModel(service: service, gateway: gateway)
        navC.pushViewController(FeedUrlInputViewController(viewModel: viewModel), animated: true)
    }

    private func didSelectShow(at indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }

        let podcast = viewModel.podcasts.value(at: indexPath)
        navigationController.pushViewController(
            PodcastEpisodeListViewController(
                playerPresenter: playerPresenter,
                podcast: podcast,
                viewModel: EpisodeListViewModel(podcast: podcast, service: service)
            ),
            animated: true
        )
    }
}
