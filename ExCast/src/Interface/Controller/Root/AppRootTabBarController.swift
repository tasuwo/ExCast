//
//  RootTabBarController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class AppRootTabBarController: UITabBarController {

    private unowned let playerPresenter: EpisodePlayerPresenter
    private let repository: PodcastRepository
    private let gateway: PodcastGateway

    // MARK: - Initializer

    init(playerPresenter: EpisodePlayerPresenter,
        repository: PodcastRepository,
        gateway: PodcastGateway) {
        self.playerPresenter = playerPresenter
        self.repository = repository
        self.gateway = gateway
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        // TODO: DI
        let viewModel = ShowListViewModel(repository: PodcastRepositoryImpl(factory: PodcastFactory(), repository: LocalRepositoryImpl(defaults: UserDefaults.standard)))

        let showListVC = PodcastShowListViewController(
            playerPresenter: self.playerPresenter,
            viewModel: viewModel,
            repository: self.repository,
            gateway: self.gateway
        )
        showListVC.tabBarItem = UITabBarItem(title: "Library", image: UIImage(named: "tabbar_library_black"), tag: 0)
        let showListNVC = UINavigationController(rootViewController: showListVC)

        self.viewControllers = [showListNVC]
    }

}
