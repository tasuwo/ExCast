//
//  DependencyContainer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

// TODO:
import Domain
import Foundation
import Infrastructure
import MediaPlayer

class DependencyContainer {
    private let podcastFactory = PodcastFactory.self
    private lazy var podcastRepository = PodcastRepository()
    private lazy var podcastGateway = PodcastGateway(session: URLSession.shared, factory: self.podcastFactory)
    private lazy var podcastService = PodcastService(repository: self.podcastRepository, gateway: self.podcastGateway)
    private lazy var episodeRepository = EpisodeRepository()
    private lazy var episodeService = EpisodeService(repository: self.episodeRepository)

    private lazy var commandCenter = MPRemoteCommandCenter.shared()
    private lazy var nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

    private lazy var playerConfiguration = PlayerConfiguration.default

    weak var episodePlayerModalPresenter: EpisodePlayerModalPresenterProtocol?
}

extension DependencyContainer: ViewControllerFactory {
    // MARK: - ViewControllerFactory

    func makeAppRootTabBarController() -> AppRootTabBarController {
        return AppRootTabBarController(factory: self)
    }

    func makeShowListViewController() -> ShowListViewController {
        let viewModel = ShowListViewModel(service: podcastService)
        return ShowListViewController(factory: self, viewModel: viewModel)
    }

    func makeFeedUrlInputViewController() -> FeedUrlInputViewController {
        let viewModel = FeedUrlInputViewModel(service: podcastService, gateway: podcastGateway)
        return FeedUrlInputViewController(factory: self, viewModel: viewModel)
    }

    func makeEpisodeListViewController(show: Show) -> EpisodeListViewController {
        let viewModel = EpisodeListViewModel(show: show, service: self.episodeService)
        return EpisodeListViewController(factory: self, viewModel: viewModel)
    }

    func makeEpisodeDetailViewController(show: Show, episode: Episode) -> EpisodeDetailViewController {
        let viewModel = EpisodeDetailViewModel(show: show, episode: episode)
        return EpisodeDetailViewController(factory: self, viewModel: viewModel)
    }

    func makeEpisodePlayerViewController(show: Show, episode: Episode) -> EpisodePlayerViewController {
        let viewModel = PlayerModalViewModel()
        return EpisodePlayerViewController(factory: self, show: show, episode: episode, viewModel: viewModel)
    }
}

extension DependencyContainer: ViewModelFactory {
    // MARK: - ViewModelFactory

    func makePlayerControllerViewModel(show: Show, episode: Episode) -> PlayerControllerViewModel {
        let player = ExCastPlayer(contentUrl: episode.meta.enclosure.url)
        let commandHandler = RemoteCommandHandler(
            show: show,
            episode: episode,
            commandCenter: commandCenter,
            player: player,
            infoCenter: nowPlayingInfoCenter,
            configuration: playerConfiguration
        )
        return PlayerControllerViewModel(show: show, episode: episode, controller: player, remoteCommands: commandHandler, configuration: playerConfiguration, episodeService: self.episodeService)
    }

    func makePlayerInformationViewModel(show: Show, episode: Episode) -> PlayerInformationViewModel {
        return PlayerInformationViewModel(show: show, episode: episode)
    }

    func makePlayingEpisodeViewModel() -> PlayingEpisodeViewModel {
        return PlayingEpisodeViewModel()
    }
}

extension DependencyContainer: EpisodePlayerModalPresenterFactory {
    // MARK: - EpisodePlayerModalPresenterFactory

    func makeEpisodePlayerModalPresenter() -> EpisodePlayerModalPresenterProtocol? {
        return episodePlayerModalPresenter
    }
}
