//
//  TimeLineViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class PodcastShowListViewController: UIViewController {

    @IBOutlet weak var showListView: PodcastShowListView!

    private unowned let layoutController: EpisodePlayerModalLaytoutController
    private let viewModel: ShowListViewModel

    // MARK: - Initializer

    init(layoutController: EpisodePlayerModalLaytoutController,
         viewModel: ShowListViewModel) {
        self.layoutController = layoutController
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        setupNavigationBar()
        self.showListView.delegate_ = self

        viewModel.podcasts ->> self.showListView.contentsBond

        self.viewModel.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.loadIfNeeded()
    }

    // MARK: - Methods

    private func setupNavigationBar() {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapTabBar))
        self.navigationItem.setRightBarButton(item, animated: true)
    }

    @objc private func didTapTabBar() {
        guard let navC = self.navigationController else { return }

        // TODO: DI
        let viewModel = FeedUrlInputViewModel(repository: PodcastGateway(session: URLSession.shared, factory: PodcastFactory(), repository: LocalRepositoryImpl(defaults: UserDefaults.standard)))

        navC.pushViewController(FeedUrlInputViewController(viewModel: viewModel), animated: true)
    }
}

extension PodcastShowListViewController: PodcastShowListViewDelegate {
    
    // MARK: - PodcastShowListViewDelegate
    
    func podcastShowListView(didSelect podcast: Podcast, at index: Int) {
        guard let navC = self.navigationController else { return }
        navC.pushViewController(PodcastEpisodeListViewController(layoutController: self.layoutController, podcast: podcast), animated: true)
    }

    func podcastShowListView(didDelete podcast: Podcast, at index: Int) {
        self.viewModel.podcasts.remove(at: index)
    }

}
