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
    private var playerModalView: EpisodePlayerViewController!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        self.rootTabBarController = AppRootTabBarController(layoutController: self)
        self.displayContentController(self.rootTabBarController)
    }

    // MARK: - Methods

    func displayContentController(_ content: UIViewController) {
        self.addChild(content)
        content.view.frame = self.view.bounds
        self.view.addSubview(content.view)
        content.didMove(toParent: self)
    }

    func hideContentController(_ content: UIViewController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    }
}

protocol EpisodePlayerModalLaytoutController: AnyObject {

    func show(show: Podcast.Show, episode: Podcast.Episode)

    func dismiss()

    func minimize()

    func expand()

}

extension AppRootViewController: EpisodePlayerModalLaytoutController {

    func show(show: Podcast.Show, episode: Podcast.Episode) {
        if let view = self.playerModalView {
            let player = AudioPlayer(episode.enclosure.url)
            view.reload(by: EpisodePlayerViewModel(show: show, episode: episode, controller: player))
            return
        }

        let player = AudioPlayer(episode.enclosure.url)
        self.playerModalView = EpisodePlayerViewController(
            layoutController: self,
            playerViewModel: EpisodePlayerViewModel(show: show, episode: episode, controller: player),
            modalViewModel: EpisodePlayerModalViewModel()
        )
        self.playerModalView.modalPresentationStyle = .formSheet
        self.playerModalView.modalTransitionStyle = .coverVertical

        self.displayContentController(self.playerModalView)
    }

    func dismiss() {
        self.hideContentController(self.playerModalView)
        self.playerModalView = nil
    }

    func minimize() {
        let tabBarInsets = self.rootTabBarController.tabBar.frame.height
        let bottom = self.view.frame.height - tabBarInsets

        self.playerModalView.view.frame = CGRect(x: 0, y: bottom - 60, width: self.view.frame.width, height: 60)
    }

    func expand() {
        self.playerModalView.view.frame = self.view.frame
    }

}
