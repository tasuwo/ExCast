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
    private lazy var episodeService = EpisodeService(podcastRepository: self.podcastRepository, episodeRepository: self.episodeRepository, gateway: self.podcastGateway)

    private lazy var commandCenter = MPRemoteCommandCenter.shared()
    private lazy var nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

    private lazy var playerConfiguration = PlayerConfiguration.default

    weak var episodePlayerModalContainerView: EpisodePlayerModalContainerViewProtocol?
    weak var episodePlayerModalBaseView: EpisodePlayerModalBaseViewProtocol?
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

    func makeEpisodeListViewController(id: Podcast.Identity, show: Show) -> EpisodeListViewController {
        let viewModel = EpisodeListViewModel(id: id, show: show, service: self.episodeService)
        let viewController = EpisodeListViewController(factory: self, viewModel: viewModel)
        return viewController
    }

    func makeEpisodeDetailViewController(show: Show, episode: Episode) -> EpisodeDetailViewController {
        let viewModel = EpisodeDetailViewModel(show: show, episode: episode)
        return EpisodeDetailViewController(factory: self, viewModel: viewModel)
    }

    func makeEpisodePlayerViewController(id: Podcast.Identity, show: Show, episode: Episode, playbackSec: Double?, playingEpisodeViewModel: PlayingEpisodeViewModel) -> EpisodePlayerViewController {
        let viewModel = PlayerModalViewModel()
        return EpisodePlayerViewController(factory: self, id: id, show: show, episode: episode, playbackSec: playbackSec, viewModel: viewModel, playingEpisodeViewModel: playingEpisodeViewModel)
    }
}

extension DependencyContainer: ViewModelFactory {
    // MARK: - ViewModelFactory

    func makePlayerControllerViewModel(show: Show, episode: Episode, playbackSec: Double?) -> PlayerControllerViewModel {
        let commandHandler = RemoteCommandHandler(
            commandCenter: commandCenter,
            infoCenter: nowPlayingInfoCenter,
            configuration: playerConfiguration
        )
        return PlayerControllerViewModel(show: show, episode: episode, playbackSec: playbackSec, remoteCommands: commandHandler, configuration: playerConfiguration, episodeService: self.episodeService)
    }

    func makePlayerInformationViewModel(id: Podcast.Identity, show: Show, episode: Episode) -> PlayerInformationViewModel {
        return PlayerInformationViewModel(id: id, show: show, episode: episode)
    }

    func makePlayingEpisodeViewModel() -> PlayingEpisodeViewModel {
        return PlayingEpisodeViewModel()
    }
}

extension DependencyContainer: EpisodePlayerModalContainerFactory {
    // MARK: - EpisodePlayerModalPresenterFactory

    func makeEpisodePlayerModalContainerView() -> EpisodePlayerModalContainerViewProtocol? {
        return self.episodePlayerModalContainerView
    }
}

extension DependencyContainer: EpisodePlayerModalBaseViewFactory {
    // MARK: - EpisodePlayerModalBaseViewFactory

    func makeEpisodePlayerModalBaseView() -> EpisodePlayerModalBaseViewProtocol? {
        return self.episodePlayerModalBaseView
    }
}
