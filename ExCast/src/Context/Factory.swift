//
//  Factory.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation

protocol ViewControllerFactory {
    func makeAppRootTabBarController() -> AppRootTabBarController

    func makeShowListViewController() -> ShowListViewController
    func makeFeedUrlInputViewController() -> FeedUrlInputViewController
    func makeEpisodeListViewController(show: Show) -> EpisodeListViewController

    func makeEpisodeDetailViewController(show: Show, episode: Episode) -> EpisodeDetailViewController
    func makeEpisodePlayerViewController(show: Show, episode: Episode) -> EpisodePlayerViewController
}

protocol ViewModelFactory {
    func makePlayerControllerViewModel(show: Show, episode: Episode) -> PlayerControllerViewModel
    func makePlayerInformationViewModel(show: Show, episode: Episode) -> PlayerInformationViewModel
    func makePlayingEpisodeViewModel() -> PlayingEpisodeViewModel
}

protocol EpisodePlayerModalContainerFactory {
    func makeEpisodePlayerModalContainerView() -> EpisodePlayerModalContainerViewProtocol?
}

protocol EpisodePlayerModalBaseViewFactory {
    func makeEpisodePlayerModalBaseView() -> EpisodePlayerModalBaseViewProtocol?
}
