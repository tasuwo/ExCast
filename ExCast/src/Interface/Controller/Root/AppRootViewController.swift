//
//  AppRootViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class AppRootViewController: UIViewController {

    private var rootTabBarController: AppRootTabBarController!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        self.rootTabBarController = AppRootTabBarController()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.show(self.rootTabBarController, sender: self)
    }
}
