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

    func presentPlayer(of listingEpisode: ListingEpisode)

    func deselectRow()
}

class EpisodeListViewModel {
    private static let sectionIdentifier = ""

    let id: Podcast.Identity
    let show: Show
    private let service: EpisodeServiceProtocol
    weak var view: EpisodeListViewProtocol?

    let playingEpisode: BehaviorRelay<PlayingEpisode?> = BehaviorRelay(value: nil)

    /// 表示中のエピソード群
    private let listingEpisodes: BehaviorRelay<Dictionary<Episode.Identity, ListingEpisode>?>

    /// エピソードリスト内の各エピソードの表示状態
    let episodeCells: BehaviorRelay<DataSourceQuery<Episode>>
    /// 再生中のエピソード特有の表示状態
    let playingEpisodeCell: BehaviorRelay<PlayingEpisodeCell?>

    private var episodeIndexPathById: BehaviorRelay<Dictionary<Episode.Identity, IndexPath>?> = BehaviorRelay(value: nil)

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(id: Podcast.Identity, show: Show, service: EpisodeServiceProtocol) {
        self.id = id
        self.show = show
        self.service = service

        self.listingEpisodes = BehaviorRelay(value: nil)
        self.episodeCells = BehaviorRelay(value: .notLoaded)
        self.playingEpisodeCell = BehaviorRelay(value: nil)

        Observable
            .combineLatest(self.episodeCells, self.playingEpisodeCell)
            .map { [unowned self] episodes, playingEpisodeCell -> Dictionary<Episode.Identity, ListingEpisode>? in
                switch episodes {
                case let .contents(models):
                    let episodes = models[0].items
                        .map { episode -> ListingEpisode in
                            if episode.id == playingEpisodeCell?.id {
                                return ListingEpisode(episode: episode, isPlaying: true, currentPlaybackSec: playingEpisodeCell?.currentPlaybackSec)
                            } else {
                                let playbackSec = self.listingEpisodes.value?[episode.identity]?.currentPlaybackSec
                                return ListingEpisode(episode: episode, isPlaying: false, currentPlaybackSec: playbackSec)
                            }
                        }
                    return episodes.reduce(into: Dictionary<Episode.Identity, ListingEpisode>()) { dic, episode in
                        dic[episode.identity] = episode
                    }
                default:
                    // TODO:
                    return self.listingEpisodes.value
                }
            }
            .bind(to: self.listingEpisodes)
            .disposed(by: self.disposeBag)

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .map { [unowned self] query -> DataSourceQuery<Episode> in
                switch query {
                case .notLoaded:
                    debugLog("The \(show.title)'s episodes state is `notLoaded`.")
                    return .notLoaded
                case let .content(_, episodes):
                    debugLog("The \(show.title)'s episodes state chaned to `content`.")

                    self.episodeIndexPathById.accept(episodes.enumerated().reduce(into: Dictionary<String, IndexPath>(), { dic, item in
                        return dic[item.element.id] = IndexPath(item: item.offset, section: 0)
                    }))

                    return .contents([.init(model: EpisodeListViewModel.sectionIdentifier, items: episodes)])
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
            .bind(to: episodeCells)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(self.episodeIndexPathById, self.playingEpisode)
            .map { dic, playingEpisode -> PlayingEpisodeCell? in
                guard let dic = dic, let playingEpisode = playingEpisode, let indexPath = dic[playingEpisode.episode.id] else { return nil }
                return .init(id: playingEpisode.episode.identity,
                             indexPath: indexPath,
                             currentPlaybackSec: playingEpisode.currentPlaybackSec)
            }
            .bind(to: self.playingEpisodeCell)
            .disposed(by: self.disposeBag)
    }

    deinit {
        self.service.command.accept(.clear)
    }

    // MARK: - Methods

    func refresh() {
        service.command.accept(.refresh(show.feedUrl))
    }

    func fetch() {
        service.command.accept(.fetch(show.feedUrl))
    }

    func didSelectEpisode(at indexPath: IndexPath) {
        guard let view = self.view else { return }
        guard case let .contents(container) = self.episodeCells.value, let episodes = container.first else { return }

        let episodeIdentity = episodes.items[indexPath.row].identity
        guard let listingEpisode = self.listingEpisodes.value?[episodeIdentity] else { return }

        view.deselectRow()

        if self.playingEpisode.value?.episode.identity == episodeIdentity {
            view.expandPlayer()
        } else {
            view.presentPlayer(of: listingEpisode)
        }
    }
}

