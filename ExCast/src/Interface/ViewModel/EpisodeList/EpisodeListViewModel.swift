//
//  EpisodeListViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxDataSources
import RxRelay
import RxSwift
import Common

class EpisodeListViewModel {
    private static let sectionIdentifier = ""

    struct ListingEpisode: Equatable {
        let episode: Episode
        let isPlaying: Bool
    }

    let show: Show
    private let service: EpisodeServiceProtocol

    let playingEpisode: BehaviorRelay<Episode?> = BehaviorRelay(value: nil)
    private(set) var episodes: BehaviorRelay<DataSourceQuery<ListingEpisode>>
    private(set) var episodesCache: BehaviorRelay<[AnimatableSectionModel<String, ListingEpisode>]>

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(show: Show, service: EpisodeServiceProtocol) {
        self.show = show
        self.service = service

        episodes = BehaviorRelay(value: .contents([]))
        episodesCache = BehaviorRelay(value: [])

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .map { [unowned self] query -> DataSourceQuery<ListingEpisode> in
                switch query {
                case let .content(episodes):
                    debugLog("The \(show.title)'s episodes state chaned to `content`.")
                    let items = episodes.map {
                        ListingEpisode(episode: $0, isPlaying: $0 == self.playingEpisode.value)
                    }
                    return .contents([.init(model: EpisodeListViewModel.sectionIdentifier, items: items)])
                case .error:
                    debugLog("The \(show.title)'s episodes state chaned to `error`.")
                    return .error
                case .progress:
                    debugLog("The \(show.title)'s episodes state chaned to `progress`.")
                    return .progress
                }
            }
            .bind(to: episodes)
            .disposed(by: disposeBag)

        playingEpisode
            .map { [unowned self] episode -> DataSourceQuery<ListingEpisode> in
                switch self.episodes.value {
                case let .contents(container) where !container.isEmpty:
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
            }
            .bind(to: episodes)
            .disposed(by: disposeBag)

        episodes
            .bind(onNext: { [unowned self] query in
                switch query {
                case let .contents(container):
                    self.episodesCache.accept(container)
                default: break
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Methods

    func fetch() {
        service.command.accept(.refresh(show.feedUrl))
    }
}

extension EpisodeListViewModel.ListingEpisode: IdentifiableType {
    // MARK: - IndetifiableTyp

    typealias Identity = String

    var identity: String {
        return episode.meta.title
    }
}
