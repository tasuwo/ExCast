//
//  RootTabBarController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class AppRootTabBarController: UITabBarController {

    private unowned let layoutController: EpisodePlayerModalLaytoutController
    private unowned let modalViewDelegate: EpisodePlayerModalViewDelegate

    // MARK: - Initializer

    init(layoutController: EpisodePlayerModalLaytoutController,
         modalViewDelegate: EpisodePlayerModalViewDelegate) {
        self.layoutController = layoutController
        self.modalViewDelegate = modalViewDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        // TODO: DI
        let viewModel = ShowListViewModel(repository: PodcastGateway(session: URLSession.shared, factory: PodcastFactory(), repository: LocalRepositoryImpl(defaults: UserDefaults.standard)))

        let showListVC = PodcastShowListViewController(layoutController: self.layoutController, modalViewDelegate: self.modalViewDelegate, viewModel: viewModel)
        showListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        let showListNVC = UINavigationController(rootViewController: showListVC)

        self.viewControllers = [showListNVC]
    }

}
