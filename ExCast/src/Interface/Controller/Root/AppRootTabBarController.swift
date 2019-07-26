//
//  RootTabBarController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class AppRootTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        // TODO: DI
        let viewModel = ShowListViewModel(repository: PodcastGateway(session: URLSession.shared, factory: PodcastFactory(), repository: LocalRepositoryImpl(defaults: UserDefaults.standard)))

        let showListVC = PodcastShowListViewController(viewModel: viewModel)
        showListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        let showListNVC = UINavigationController(rootViewController: showListVC)

        self.viewControllers = [showListNVC]
    }

}
