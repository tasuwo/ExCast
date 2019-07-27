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
        self.rootTabBarController = AppRootTabBarController(layoutController: self, modalViewDelegate: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.show(self.rootTabBarController, sender: self)
    }
}

protocol EpisodePlayerModalLaytoutController: AnyObject {

    func show(episode: Podcast.Episode)

}

extension AppRootViewController: EpisodePlayerModalLaytoutController {

    func show(episode: Podcast.Episode) {
        let controller = AudioPlayer(episode.enclosure.url)
        let viewModel = EpisodePlayerViewModel(controller: controller, episode: episode)

        self.playerModalView = EpisodePlayerViewController(layoutController: self, modalViewDelegate: self, viewModel: viewModel)
        self.playerModalView.modalPresentationStyle = .formSheet
        self.playerModalView.modalTransitionStyle = .coverVertical

        self.rootTabBarController.show(self.playerModalView, sender: nil)
    }

}

extension AppRootViewController: EpisodePlayerModalViewDelegate {

    // MARK: - EpisodePlayerModalViewDelegate

    func didTapToggleButton() {
        self.playerModalView.dismiss(animated: true, completion: nil)
        self.playerModalView = nil
    }

    func didTapView() {
        // NOP:
    }

}
