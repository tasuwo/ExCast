//
//  EpisodeListViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources
import RxRelay
import RxSwift

struct EpisodeListViewModel {
    private static let sectionIdentifier = ""

    struct ListingEpisode: Equatable {
        let episode: Podcast.Episode
        let isPlaying: Bool
    }

    let show: Podcast.Show
    private let feedUrl: URL
    private let service: PodcastServiceProtocol

    let playingEpisode: BehaviorRelay<Podcast.Episode?> = BehaviorRelay(value: nil)
    private(set) var episodes: BehaviorRelay<DataSourceQuery<ListingEpisode>>
    private(set) var episodesCache: BehaviorRelay<[AnimatableSectionModel<String, ListingEpisode>]>

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(podcast: Podcast, service: PodcastServiceProtocol) {
        feedUrl = podcast.show.feedUrl
        self.service = service

        self.show = podcast.show
        self.episodes = BehaviorRelay(value: .contents([
            .init(model: EpisodeListViewModel.sectionIdentifier,
                  items: podcast.episodes.map { ListingEpisode(episode: $0, isPlaying: false) })
        ]))
        self.episodesCache = BehaviorRelay(value: [
            .init(model: EpisodeListViewModel.sectionIdentifier,
                  items: podcast.episodes.map { ListingEpisode(episode: $0, isPlaying: false) })
        ])

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .map({ [self] query -> DataSourceQuery<ListingEpisode> in
                switch query {
                case let .content(podcasts):
                    // TODO: 効率化
                    guard let podcast = podcasts.first(where: { $0.show.feedUrl == self.feedUrl }) else {
                        return .error
                    }
                    let items = podcast.episodes.map {
                        ListingEpisode(episode: $0, isPlaying: $0 == self.playingEpisode.value)
                    }
                    return .contents([ .init(model: EpisodeListViewModel.sectionIdentifier, items: items) ])
                case .error:
                    return .error
                case .progress:
                    return .progress
                }
            })
            .bind(to: self.episodes)
            .disposed(by: self.disposeBag)

        self.playingEpisode
            .map({ [self] episode -> DataSourceQuery<ListingEpisode> in
                switch self.episodes.value {
                case let .contents(container):
                    if episode == nil {
                        guard let firstIndex = container[0].items.firstIndex(where: { $0.isPlaying == true }) else {
                            return self.episodes.value
                        }
                        var episodes = container[0].items
                        episodes[firstIndex] = .init(episode: episodes[firstIndex].episode, isPlaying: false)
                        return .contents([.init(model: container[0].identity, items: episodes)])
                    } else {
                        var episodes = container[0].items

                        if let firstIndex1 = container[0].items.firstIndex(where: { $0.isPlaying == true }) {
                            episodes[firstIndex1] = .init(episode: episodes[firstIndex1].episode, isPlaying: false)
                        }

                        guard let firstIndex2 = container[0].items.firstIndex(where: { $0.episode == episode }) else {
                            return self.episodes.value
                        }
                        episodes[firstIndex2] = .init(episode: episodes[firstIndex2].episode, isPlaying: true)
                        return .contents([.init(model: container[0].identity, items: episodes)])
                    }
                default:
                    return self.episodes.value
                }
            })
            .bind(to: self.episodes)
            .disposed(by: self.disposeBag)

        self.episodes
            .bind(onNext: { [self] query in
                switch query {
                case let .contents(container):
                    self.episodesCache.accept(container)
                default: break
                }
            })
            .disposed(by: self.disposeBag)
    }

    // MARK: - Methods

    func fetch(url: URL) {
        self.service.command.accept(.fetch(url))
    }
}

extension EpisodeListViewModel.ListingEpisode: IdentifiableType {
    // MARK: - IndetifiableType

    typealias Identity = String

    var identity: String {
        return self.episode.title
    }
}
