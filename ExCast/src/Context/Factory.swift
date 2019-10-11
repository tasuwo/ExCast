//
//  Factory.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

protocol ViewControllerFactory {
    func makeAppRootTabBarController() -> AppRootTabBarController

    func makePodcastShowListViewController() -> PodcastShowListViewController
    func makeFeedUrlInputViewController() -> FeedUrlInputViewController
    func makeEpisodeListViewController(podcast: Podcast) -> PodcastEpisodeListViewController

    func makeEpisodeDetailViewController(show: Podcast.Show, episode: Podcast.Episode) -> EpisodeDetailViewController
    func makeEpisodePlayerViewController(show: Podcast.Show, episode: Podcast.Episode) -> EpisodePlayerViewController
}

protocol ViewModelFactory {
    func makePlayerControllerViewModel(show: Podcast.Show, episode: Podcast.Episode) -> PlayerControllerViewModel
    func makePlayerInformationViewModel(show: Podcast.Show, episode: Podcast.Episode) -> PlayerInformationViewModel
}

protocol EpisodePlayerModalPresenterFactory {
    func makeEpisodePlayerModalPresenter() -> EpisodePlayerModalPresenterProtocol?
}
