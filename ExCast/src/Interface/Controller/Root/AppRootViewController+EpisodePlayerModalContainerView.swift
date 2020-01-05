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

    var playingEpisode: BehaviorRelay<EpisodeBelongsToShow?> { get }

    var currentEpisodeDuration: BehaviorRelay<Double?> { get }

    var playerModal: EpisodePlayerModalProtocol? { get }

    func presentPlayerModal(show: Show, episode: Episode)
}

protocol EpisodePlayerModalProtocol {

    func changeToFullScreenIfPossible()

    func changeToMinimizeIfPossible()
}

extension AppRootViewController: EpisodePlayerModalContainerViewProtocol {
    // MARK: - EpisodePlayerModalPresenterProtocol

    var playingEpisode: BehaviorRelay<EpisodeBelongsToShow?> {
        return self.playingEpisodeViewModel.playingEpisode
    }

    var currentEpisodeDuration: BehaviorRelay<Double?> {
        return self.playingEpisodeViewModel.currentDuration
    }

    var playerModal: EpisodePlayerModalProtocol? {
        return self.playerModalViewController
    }

    func presentPlayerModal(show: Show, episode: Episode) {
        if let view = self.playerModalViewController {
            view.reload(
                controllerViewModel: self.factory.makePlayerControllerViewModel(show: show, episode: episode),
                informationViewModel: self.factory.makePlayerInformationViewModel(show: show, episode: episode)
            )
            return
        }

        let playerViewController = self.factory.makeEpisodePlayerViewController(show: show,
                                                                                episode: episode,
                                                                                playingEpisodeViewModel: self.playingEpisodeViewModel)
        playerViewController.modalPresentationStyle = .formSheet
        playerViewController.modalTransitionStyle = .coverVertical

        displayContentController(playerViewController)

        self.playerModalViewController = playerViewController

        let newSafeArea = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        self.rootTabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets = newSafeArea }
    }
}
