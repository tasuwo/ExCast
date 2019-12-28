//
//  RootTabBarController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class AppRootTabBarController: UITabBarController {
    typealias Factory = ViewControllerFactory

    private let factory: Factory

    // MARK: - Initializer

    init(factory: Factory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        let showListViewController = factory.makeShowListViewController()

        showListViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Tabbar.library", comment: ""), image: UIImage(named: "tabbar_library_black"), tag: 0)
        let showListNavigationViewController = UINavigationController(rootViewController: showListViewController)

        viewControllers = [showListNavigationViewController]
    }
}
