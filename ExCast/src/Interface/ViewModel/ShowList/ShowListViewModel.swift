//
//  TimelineViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Domain
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

protocol ShowListViewModelType {
    var inputs: ShowListViewModelInputs { get }
    var outputs: ShowListViewModelOutputs { get }
}

protocol ShowListViewModelInputs {
    var podcastsLoaded: PublishRelay<Void> { get }
    var podcastSelected: PublishRelay<IndexPath> { get }
    var podcastDeleted: PublishRelay<IndexPath> { get }
}

protocol ShowListViewModelOutputs {
    var podcasts: Driver<[AnimatableSectionModel<String, Podcast>]> { get }
    var isLoading: Driver<Bool> { get }

    var episodesViewPresented: Signal<Podcast> { get }
}

class ShowListViewModel: ShowListViewModelType, ShowListViewModelInputs, ShowListViewModelOutputs {
    private static let sectionIdentifier = ""

    // MARK: - ShowListViewModelType

    var inputs: ShowListViewModelInputs { return self }
    var outputs: ShowListViewModelOutputs { return self }

    // MARK: - ShowListViewModelInputs

    var podcastsLoaded: PublishRelay<Void>
    var podcastSelected: PublishRelay<IndexPath>
    var podcastDeleted: PublishRelay<IndexPath>

    // MARK: = ShowListViewModelOutputs

    var podcasts: Driver<[AnimatableSectionModel<String, Podcast>]>
    var isLoading: Driver<Bool>
    var episodesViewPresented: Signal<Podcast>

    // MARK: - Privates

    private var _podcasts: BehaviorRelay<[Podcast]> = .init(value: [])
    private var _isLoading: BehaviorRelay<Bool> = .init(value: false)
    private var _episodesPresented: PublishRelay<Podcast> = .init()
    private let service: PodcastServiceProtocol

    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(service: PodcastServiceProtocol) {
        // MARK: Privates

        self.service = service

        // MARK: Inputs

        self.podcastsLoaded = .init()
        self.podcastSelected = .init()
        self.podcastDeleted = .init()

        // MARK: Outputs

        self.podcasts = self._podcasts
            .map { [AnimatableSectionModel(model: ShowListViewModel.sectionIdentifier, items: $0)] }
            .asDriver(onErrorDriveWith: .empty())
        self.isLoading = self._isLoading
            .asDriver(onErrorDriveWith: .empty())
        self.episodesViewPresented = self._episodesPresented
            .asSignal(onErrorSignalWith: .empty())

        // MARK: Binding

        // Apply loaded/fetched podcasts

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> [Podcast]? in
                guard case let .content(podcasts) = query else { return nil }
                return podcasts
            }
            .bind(to: self._podcasts)
            .disposed(by: self.disposeBag)

        self.service.state
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .compactMap { query -> Bool? in
                guard case .progress = query else { return false }
                return true
            }
            .bind(to: self._isLoading)
            .disposed(by: self.disposeBag)

        // Handling inputs

        self.podcastsLoaded
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._isLoading.accept(true)
                self.service.command.accept(.refresh)
            })
            .disposed(by: self.disposeBag)

        self.podcastSelected
            .compactMap { [weak self] indexPath in
                self?._podcasts.value[indexPath.row]
            }
            .bind(to: self._episodesPresented)
            .disposed(by: self.disposeBag)

        self.podcastDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self._isLoading.accept(true)
                self.service.command.accept(.delete(self._podcasts.value[indexPath.row]))
            })
            .disposed(by: self.disposeBag)
    }
}
