//
//  EpisodeListViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Domain
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

protocol EpisodeListViewModelType {
    var inputs: EpisodeListViewModelInputs { get }
    var outputs: EpisodeListViewModelOutputs { get }
}

protocol EpisodeListViewModelInputs {
    var episodePlayed: PublishRelay<PlayingEpisode?> { get }
    var episodeSelected: PublishRelay<IndexPath> { get }
    var episodesLoaded: PublishRelay<Void> { get }
    var episodesFetched: PublishRelay<Void> { get }
}

protocol EpisodeListViewModelOutputs {
    var id: Podcast.Identity { get }
    var show: Show { get }

    var episodes: Driver<[AnimatableSectionModel<String, Episode>]> { get }
    var playingEpisode: Driver<ListingEpisode?> { get }
    var isLoading: Driver<Bool> { get }

    var rowDeselected: Signal<Void> { get }
    var playerExpanded: Signal<Void> { get }
    var playerPresented: Signal<ListingEpisode> { get }
}

final class EpisodeListViewModel: EpisodeListViewModelType, EpisodeListViewModelInputs, EpisodeListViewModelOutputs {
    private static let sectionIdentifier = "EpisodeListViewModel"

    // MARK: - EpisodeListViewModelType

    var inputs: EpisodeListViewModelInputs { return self }
    var outputs: EpisodeListViewModelOutputs { return self }

    // MARK: - EpisodeListViewModelInputs

    let episodePlayed: PublishRelay<PlayingEpisode?>
    let episodeSelected: PublishRelay<IndexPath>
    let episodesLoaded: PublishRelay<Void>
    let episodesFetched: PublishRelay<Void>

    // MARK: - EpisodeListViewModelOutputs

    let id: Podcast.Identity
    let show: Show
    let episodes: Driver<[AnimatableSectionModel<String, Episode>]>

    let playingEpisode: Driver<ListingEpisode?>
    let isLoading: Driver<Bool>

    let rowDeselected: Signal<Void>
    let playerExpanded: Signal<Void>
    let playerPresented: Signal<ListingEpisode>

    // MARK: - Privates

    private let _listingEpisodes: BehaviorRelay<[Episode.Identity: ListingEpisode]> = .init(value: [:])
    private let _episodes: BehaviorRelay<[Episode]> = .init(value: [])
    private let _playingEpisode: BehaviorRelay<ListingEpisode?> = .init(value: nil)
    private let _isLoading: BehaviorRelay<Bool> = .init(value: false)

    private let _newEpisodeSelected: PublishRelay<ListingEpisode>
    private let _playingEpisodeSelected: PublishRelay<ListingEpisode>

    private let service: EpisodeServiceProtocol

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(id: Podcast.Identity, show: Show, service: EpisodeServiceProtocol) {
        // MARK: Privates

        self._newEpisodeSelected = PublishRelay<ListingEpisode>()
        self._playingEpisodeSelected = PublishRelay<ListingEpisode>()
        self.service = service

        // MARK: Inputs

        self.episodePlayed = PublishRelay<PlayingEpisode?>()
        self.episodeSelected = PublishRelay<IndexPath>()
        self.episodesLoaded = PublishRelay<Void>()
        self.episodesFetched = PublishRelay<Void>()

        // MARK: Outputs

        self.id = id
        self.show = show
        self.episodes = self._episodes
            .map { [AnimatableSectionModel(model: EpisodeListViewModel.sectionIdentifier, items: $0)] }
            .asDriver(onErrorDriveWith: .empty())
        self.playingEpisode = self._playingEpisode.asDriver()
        self.isLoading = self._isLoading
            .asDriver(onErrorDriveWith: .empty())
        self.rowDeselected = self.episodeSelected
            .map { _ in () }
            .asSignal(onErrorJustReturn: ())
        self.playerExpanded = self._playingEpisodeSelected
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())
        self.playerPresented = self._newEpisodeSelected
            .asSignal(onErrorSignalWith: .empty())

        // MARK: Binding

        // Apply loaded/fetched episodes

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> [Episode]? in
                guard case let .content(_, episodes) = query else { return nil }
                return episodes
            }
            .bind(to: self._episodes)
            .disposed(by: disposeBag)

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> Bool? in
                guard case .progress = query else { return false }
                return true
            }
            .bind(to: self._isLoading)
            .disposed(by: disposeBag)

        // Apply playing episode

        self.episodePlayed
            .map { [weak self] playingEpisode -> ListingEpisode? in
                // TODO: パフォーマンスを向上させる
                return self?._listingEpisodes.value
                    .first(where: { $0.value.episode.id == playingEpisode?.episode.id })?.value
                    .updated(playbackSec: playingEpisode?.currentPlaybackSec)
            }
            .bind(to: self._playingEpisode)
            .disposed(by: self.disposeBag)

        // Store listing episodes' models

        Observable
            .combineLatest(self._episodes, self._playingEpisode)
            .compactMap { [weak self] episodes, playingEpisode -> [Episode.Identity: ListingEpisode]? in
                guard let self = self else { return nil }
                return type(of: self).buildListingEpisodes(by: episodes, with: playingEpisode, for: self._listingEpisodes.value)
            }
            .bind(to: self._listingEpisodes)
            .disposed(by: self.disposeBag)

        // Handling inputs

        let selectedEpisode = self.episodeSelected
            .compactMap { [weak self] indexPath -> ListingEpisode? in
                // TODO: パフォーマンスを向上させる
                return self?._listingEpisodes.value.first(where: { $0.value.indexPath == indexPath })?.value
            }
        selectedEpisode
            .filter { [weak self] e in e.identity == self?._playingEpisode.value?.episode.identity }
            .bind(to: self._playingEpisodeSelected)
            .disposed(by: self.disposeBag)
        selectedEpisode
            .filter { [weak self] e in e.identity != self?._playingEpisode.value?.episode.identity }
            .bind(to: self._newEpisodeSelected)
            .disposed(by: self.disposeBag)

        self.episodesLoaded
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._isLoading.accept(true)
                self.service.command.accept(.refresh(self.show.feedUrl))
            })
            .disposed(by: self.disposeBag)

        self.episodesFetched
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._isLoading.accept(true)
                self.service.command.accept(.fetch(self.show.feedUrl))
            })
            .disposed(by: self.disposeBag)
    }

    deinit {
        self.service.command.accept(.clear)
    }
}

extension EpisodeListViewModel {
    static func buildListingEpisodes(by episodes: [Episode],
                                     with playingEpisode: ListingEpisode?,
                                     for currentEpisodes: [Episode.Identity: ListingEpisode]) -> [Episode.Identity: ListingEpisode] {
        return episodes.enumerated().map { index, episode -> ListingEpisode in
            if episode.id == playingEpisode?.identity {
                return ListingEpisode(indexPath: .init(row: index, section: 0),
                                      episode: episode,
                                      isPlaying: true,
                                      currentPlaybackSec: playingEpisode?.currentPlaybackSec)
            } else {
                let playbackSec = currentEpisodes[episode.identity]?.currentPlaybackSec
                return ListingEpisode(indexPath: .init(row: index, section: 0),
                                      episode: episode,
                                      isPlaying: false,
                                      currentPlaybackSec: playbackSec)
            }
        }.reduce(into: [Episode.Identity: ListingEpisode]()) { dic, episode in
            dic[episode.identity] = episode
        }
    }
}
