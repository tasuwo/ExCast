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
    private let service: PodcastService
    private let gateway: PodcastGateway

    // MARK: - Initializer

    init(playerPresenter: EpisodePlayerPresenter,
         service: PodcastService,
         gateway: PodcastGateway) {
        self.playerPresenter = playerPresenter
        self.service = service
        self.gateway = gateway
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        let viewModel = ShowListViewModel(service: service)

        let showListVC = PodcastShowListViewController(
            playerPresenter: playerPresenter,
            viewModel: viewModel,
            service: service,
            gateway: gateway
        )
        showListVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Tabbar.library", comment: ""), image: UIImage(named: "tabbar_library_black"), tag: 0)
        let showListNVC = UINavigationController(rootViewController: showListVC)

        viewControllers = [showListNVC]
    }
}
