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

protocol EpisodeListViewProtocol: AnyObject {
    func expandPlayer()
    func presentPlayer(of episode: Episode)
}

class EpisodeListViewModel {
    private static let sectionIdentifier = ""

    let show: Show
    private let service: EpisodeServiceProtocol
    weak var view: EpisodeListViewProtocol?

    let playingEpisode: BehaviorRelay<EpisodeBelongsToShow?> = BehaviorRelay(value: nil)
    private(set) var episodes: BehaviorRelay<DataSourceQuery<ListingEpisode>>
    private(set) var episodesCache: BehaviorRelay<[ListingEpisode]>

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(show: Show, service: EpisodeServiceProtocol) {
        self.show = show
        self.service = service

        episodes = BehaviorRelay(value: .notLoaded)
        episodesCache = BehaviorRelay(value: [])

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .map { [unowned self] query -> DataSourceQuery<ListingEpisode> in
                switch query {
                case .notLoaded:
                    debugLog("The \(show.title)'s episodes state is `notLoaded`.")
                    return .notLoaded
                case let .content(_, episodes):
                    debugLog("The \(show.title)'s episodes state chaned to `content`.")
                    let items = episodes.map {
                        ListingEpisode(episode: $0, isPlaying: $0 == self.playingEpisode.value?.episode)
                    }
                    return .contents([.init(model: EpisodeListViewModel.sectionIdentifier, items: items)])
                case .error:
                    debugLog("The \(show.title)'s episodes state chaned to `error`.")
                    return .error
                case .progress:
                    debugLog("The \(show.title)'s episodes state chaned to `progress`.")
                    return .progress
                case .clear:
                    debugLog("The \(show.title)'s episodes state chaned to `clear`.")
                    return .notLoaded
                }
            }
            .bind(to: episodes)
            .disposed(by: disposeBag)

        playingEpisode
            .map { [unowned self] playingEpisode -> DataSourceQuery<ListingEpisode> in
                switch (playingEpisode, self.episodes.value) {
                case (.none, let .contents(container)) where container.isEmpty == false:
                    let items = container.first!.items.map { episode in
                        episode.isPlaying ? episode.finishedPlay() : episode
                    }
                    return .contents([.init(model: EpisodeListViewModel.sectionIdentifier, items: items)])
                case (let .some(targetEpisode), let .contents(container)) where container.isEmpty == false:
                    let items = container.first!.items.map { episode in
                        episode.isPlaying ? episode.finishedPlay() : episode
                    }.map { episode in
                        episode.identity == targetEpisode.episode.identity ? episode.startedPlay() : episode
                    }
                    return .contents([.init(model: EpisodeListViewModel.sectionIdentifier, items: items)])
                default:
                    return self.episodes.value
                }
            }
            .bind(to: episodes)
            .disposed(by: disposeBag)

        Observable
            .zip(self.playingEpisode, self.playingEpisode.skip(1))
            .flatMap { diff -> Single<EpisodeServiceCommand> in
                switch diff {
                case let (.none, .some(current)) where current.show == self.show:
                    // TODO: Podcast の Identity を参照する
                    return .just(.refresh(self.show.feedUrl))
                case let (.some(prev), .some(current)) where prev.show == self.show || current.show == self.show:
                    // TODO: Podcast の Identity を参照する
                    return .just(.refresh(self.show.feedUrl))
                case let (.some(prev), .none) where prev.show == self.show:
                    // TODO: Podcast の Identity を参照する
                    return .just(.refresh(self.show.feedUrl))
                default:
                    return .never()
                }
            }
            .bind(to: self.service.command)
            .disposed(by: self.disposeBag)

        episodes
            .bind(onNext: { [unowned self] query in
                switch query {
                case let .contents(container) where container.isEmpty == false:
                    self.episodesCache.accept(container.first!.items)
                default: break
                }
            })
            .disposed(by: disposeBag)
    }

    deinit {
        self.service.command.accept(.clear)
    }

    // MARK: - Methods

    func fetch() {
        service.command.accept(.refresh(show.feedUrl))
    }

    func didSelectEpisode(at indexPath: IndexPath) {
        let episode = self.episodesCache.value[indexPath.row].episode

        if self.playingEpisode.value?.episode.identity == episode.identity {
            self.view?.expandPlayer()
        } else {
            self.view?.presentPlayer(of: episode)
        }
    }
}

