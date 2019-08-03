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
        self.rootTabBarController = AppRootTabBarController(
            playerPresenter: self,
            repository: PodcastRepositoryImpl(factory: PodcastFactory(), repository: LocalRepositoryImpl(defaults: UserDefaults.standard)),
            gateway: PodcastGatewayImpl(session: URLSession.shared, factory: PodcastFactory())
        )
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

extension AppRootViewController: EpisodePlayerPresenter {

    func show(show: Podcast.Show, episode: Podcast.Episode) {
        if let view = self.playerModalView {
            let player = AudioPlayer(episode.enclosure.url)
            view.reload(by: EpisodePlayerControllerViewModel(show: show, episode: episode, controller: player))
            return
        }

        let player = AudioPlayer(episode.enclosure.url)
        self.playerModalView = EpisodePlayerViewController(
            presenter: self,
            viewModel: EpisodePlayerControllerViewModel(show: show, episode: episode, controller: player),
            informationViewModel: EpisodePlayerInformationViewModel(show: show, episode: episode),
            modalViewModel: EpisodePlayerModalViewModel()
        )
        self.playerModalView.modalPresentationStyle = .formSheet
        self.playerModalView.modalTransitionStyle = .coverVertical

        self.displayContentController(self.playerModalView)

        let newSafeArea = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        self.rootTabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets = newSafeArea }
    }

    func dismiss() {
        self.hideContentController(self.playerModalView)
        self.playerModalView = nil

        let newSafeArea = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.rootTabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets = newSafeArea }
    }

    func minimize() {
        let tabBarInsets = self.rootTabBarController.tabBar.frame.height
        let bottom = self.view.frame.height - tabBarInsets

        self.playerModalView.view.frame = CGRect(x: 0, y: bottom - 70, width: self.view.frame.width, height: 70)
        self.playerModalView.view.layoutIfNeeded()
    }

    func expand() {
        self.playerModalView.view.frame = self.view.frame
        self.playerModalView.view.layoutIfNeeded()
    }

}
