//
//  AppRootViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxRelay
import UIKit

class AppRootViewController: UIViewController {
    typealias Factory = ViewControllerFactory & ViewModelFactory

    let rootTabBarController: AppRootTabBarController
    var playerModalViewController: EpisodePlayerViewController?

    let playingEpisodeViewModel: PlayingEpisodeViewModel

    let factory: Factory

    // MARK: - Lifecycle

    init(factory: Factory) {
        self.factory = factory
        self.rootTabBarController = factory.makeAppRootTabBarController()
        self.playingEpisodeViewModel = factory.makePlayingEpisodeViewModel()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayContentController(rootTabBarController)
    }

    // MARK: - Methods

    func displayContentController(_ content: UIViewController) {
        addChild(content)
        content.view.frame = view.bounds
        view.addSubview(content.view)
        content.didMove(toParent: self)
    }

    func hideContentController(_ content: UIViewController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    }
}

extension AppRootViewController: EpisodePlayerModalBaseViewProtocol {
    // MARK: - EpisodePlayerModalBaseViewProtocol

    func dismiss() {
        guard let playerViewController = self.playerModalViewController else { return }

        hideContentController(playerViewController)
        playerModalViewController = nil

        let newSafeArea = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rootTabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets = newSafeArea }

        self.playingEpisodeViewModel.clear()
    }

    func minimize() {
        guard let playerViewController = self.playerModalViewController else { return }

        let tabBarInsets = rootTabBarController.tabBar.frame.height
        let bottom = view.frame.height - tabBarInsets

        playerViewController.view.frame = CGRect(x: 0, y: bottom - 70, width: view.frame.width, height: 70)
        playerViewController.view.layoutIfNeeded()
    }

    func expand() {
        guard let playerViewController = self.playerModalViewController else { return }

        playerViewController.view.frame = view.frame
        playerViewController.view.layoutIfNeeded()
    }
}
