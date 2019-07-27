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
        self.rootTabBarController = AppRootTabBarController(modalViewDelegate: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.show(self.rootTabBarController, sender: self)
    }
}

extension AppRootViewController: EpisodePlayerModalViewDelegate {

    // MARK: - AnonymousProtocol

    func show(episode: Podcast.Episode) {
        let controller = AudioPlayer(episode.enclosure.url)
        let viewModel = EpisodePlayerViewModel(controller: controller, episode: episode)

        self.playerModalView = EpisodePlayerViewController(modalViewDelegate: self, viewModel: viewModel)
        self.playerModalView.modalPresentationStyle = .formSheet
        self.playerModalView.modalTransitionStyle = .coverVertical

        self.rootTabBarController.show(self.playerModalView, sender: nil)
    }

    func hide() {
        self.playerModalView.dismiss(animated: true, completion: nil)
        self.playerModalView = nil
    }

}
