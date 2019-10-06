//
//  AppRootViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MediaPlayer

class AppRootViewController: UIViewController {

    private var rootTabBarController: AppRootTabBarController!
    private var playerModalViewController: EpisodePlayerViewController?

    private weak var delegate: EpisodePlayerPresenterDelegate?

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

    func playingEpisode() -> Podcast.Episode? {
        return self.playerModalViewController?.playingEpisode
    }

    func setDelegate(_ delegate: EpisodePlayerPresenterDelegate) {
        self.delegate = delegate
    }

    func show(show: Podcast.Show, episode: Podcast.Episode, configuration: PlayerConfiguration) {
        let player = ExCastPlayer(contentUrl: episode.enclosure.url)
        let commandHandler = RemoteCommandHandler(
            show: show,
            episode: episode,
            commandCenter: MPRemoteCommandCenter.shared(),
            player: player,
            infoCenter: MPNowPlayingInfoCenter.default(),
            configuration: configuration
        )

        if let view = self.playerModalViewController {
            view.reload(
                controllerViewModel: PlayerControllerViewModel(show: show, episode: episode, controller: player,remoteCommands: commandHandler, configuration: configuration),
                informationViewModel: PlayerInformationViewModel(show: show, episode: episode)
            )
            return
        }

        let playerViewController = EpisodePlayerViewController(
            presenter: self,
            viewModel: PlayerControllerViewModel(show: show, episode: episode, controller: player, remoteCommands: commandHandler, configuration: configuration),
            informationViewModel: PlayerInformationViewModel(show: show, episode: episode),
            modalViewModel: PlayerModalViewModel()
        )
        playerViewController.modalPresentationStyle = .formSheet
        playerViewController.modalTransitionStyle = .coverVertical

        self.displayContentController(playerViewController)

        self.playerModalViewController = playerViewController

        let newSafeArea = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        self.rootTabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets = newSafeArea }
    }

    func dismiss() {
        guard let playerViewController = self.playerModalViewController else { return }

        self.hideContentController(playerViewController)
        self.playerModalViewController = nil

        let newSafeArea = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.rootTabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets = newSafeArea }

        self.delegate?.didDismissPlayer()
    }

    func minimize() {
        guard let playerViewController = self.playerModalViewController else { return }

        let tabBarInsets = self.rootTabBarController.tabBar.frame.height
        let bottom = self.view.frame.height - tabBarInsets

        playerViewController.view.frame = CGRect(x: 0, y: bottom - 70, width: self.view.frame.width, height: 70)
        playerViewController.view.layoutIfNeeded()
    }

    func expand() {
        guard let playerViewController = self.playerModalViewController else { return }

        playerViewController.view.frame = self.view.frame
        playerViewController.view.layoutIfNeeded()
    }

}
