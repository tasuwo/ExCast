//
//  AppRootViewController+EpisodePOlayerModalContainerView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxRelay

protocol EpisodePlayerModalContainerViewProtocol: AnyObject {
    var playingEpisode: BehaviorRelay<PlayingEpisode?> { get }

    var playerModal: EpisodePlayerModalProtocol? { get }

    func presentPlayerModal(id: Podcast.Identity, show: Show, episode: Episode, playbackSec: Double?)
}

protocol EpisodePlayerModalProtocol {
    func changeToFullScreenIfPossible()

    func changeToMinimizeIfPossible()
}

extension AppRootViewController: EpisodePlayerModalContainerViewProtocol {
    // MARK: - EpisodePlayerModalPresenterProtocol

    var playingEpisode: BehaviorRelay<PlayingEpisode?> {
        return self.playingEpisodeViewModel.playingEpisode
    }

    var playerModal: EpisodePlayerModalProtocol? {
        return self.playerModalViewController
    }

    func presentPlayerModal(id: Podcast.Identity, show: Show, episode: Episode, playbackSec: Double?) {
        if let view = self.playerModalViewController {
            view.reload(
                controllerViewModel: self.factory.makePlayerControllerViewModel(show: show, episode: episode, playbackSec: playbackSec),
                informationViewModel: self.factory.makePlayerInformationViewModel(id: id, show: show, episode: episode)
            )
            return
        }

        let playerViewController = self.factory.makeEpisodePlayerViewController(id: id,
                                                                                show: show,
                                                                                episode: episode,
                                                                                playbackSec: playbackSec,
                                                                                playingEpisodeViewModel: self.playingEpisodeViewModel)
        playerViewController.modalPresentationStyle = .formSheet
        playerViewController.modalTransitionStyle = .coverVertical

        displayContentController(playerViewController)

        self.playerModalViewController = playerViewController

        let newSafeArea = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        self.rootTabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets = newSafeArea }
    }
}
