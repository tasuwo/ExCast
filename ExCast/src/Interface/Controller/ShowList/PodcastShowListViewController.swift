//
//  TimeLineViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PodcastShowListViewController: UIViewController {

    @IBOutlet weak var showListView: PodcastShowListView!
    private let dataSourceContainer = PodcastShowListViewDataSourceContainer()

    private unowned let playerPresenter: EpisodePlayerPresenter
    private let viewModel: ShowListViewModel

    private let repository: PodcastRepository
    private let gateway: PodcastGateway

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(playerPresenter: EpisodePlayerPresenter,
         viewModel: ShowListViewModel,
         repository: PodcastRepository,
         gateway: PodcastGateway) {
        self.playerPresenter = playerPresenter
        self.viewModel = viewModel

        self.repository = repository
        self.gateway = gateway

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        self.viewModel.podcasts
            .bind(to: self.showListView.rx.items(dataSource: self.dataSourceContainer.dataSource))
            .disposed(by: self.disposeBag)

        self.showListView.rx.itemDeleted
            .map { $0.row }
            .bind(onNext: self.viewModel.remove(at:))
            .disposed(by: self.disposeBag)
        
        self.showListView.rx.itemSelected
            .bind(onNext: self.didSelectShow(at:))
            .disposed(by: self.disposeBag)


        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil,
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewModel.load()

        self.title = NSLocalizedString("PodcastShowListView.title", comment: "")

        if let selectedRow = self.showListView.indexPathForSelectedRow {
            self.showListView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Methods

    private func setupNavigationBar() {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapTabBar))
        self.navigationItem.setRightBarButton(item, animated: true)
    }

    @objc private func didTapTabBar() {
        guard let navC = self.navigationController else { return }
        let viewModel = FeedUrlInputViewModel(repository: self.repository, gateway: self.gateway)
        navC.pushViewController(FeedUrlInputViewController(viewModel: viewModel), animated: true)
    }

    private func didSelectShow(at indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }

        let podcast = self.viewModel.podcasts.value(at: indexPath)
        navigationController.pushViewController(
            PodcastEpisodeListViewController(
                playerPresenter: self.playerPresenter,
                podcast: podcast,
                viewModel: EpisodeListViewModel(podcast: podcast, gateway: self.gateway)
            ),
            animated: true
        )
    }

}
