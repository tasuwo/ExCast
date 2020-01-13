//
//  TimelineViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Domain
import RxDataSources
import RxRelay
import RxSwift

class ShowListViewModel {
    private static let sectionIdentifier = ""

    private(set) var podcasts: BehaviorRelay<DataSourceQuery<Podcast>>
    private(set) var podcastsCache: BehaviorRelay<[AnimatableSectionModel<String, Podcast>]>
    private let service: PodcastServiceProtocol

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(service: PodcastServiceProtocol) {
        self.service = service
        self.service.command.accept(.refresh)

        self.podcasts = BehaviorRelay(value: .notLoaded)
        self.podcastsCache = BehaviorRelay(value: [])

        self.service.state
            .compactMap { state -> DataSourceQuery<Podcast> in
                switch state {
                case .notLoaded:
                    debugLog("The show list state is `notLoaded`.")
                    return .notLoaded
                case let .content(podcasts):
                    debugLog("The show list state chaned to `content`.")
                    return .contents([.init(model: ShowListViewModel.sectionIdentifier, items: podcasts)])
                case .error:
                    debugLog("The show list state chaned to `error`.")
                    return .error
                case .progress:
                    debugLog("The show list state chaned to `progress`.")
                    return .progress
                }
            }
            .bind(to: podcasts)
            .disposed(by: disposeBag)

        self.podcasts
            .bind(onNext: { [unowned self] query in
                switch query {
                case let .contents(container):
                    self.podcastsCache.accept(container)
                default: break
                }
            }).disposed(by: self.disposeBag)
    }

    // MARK: - Methods

    func remove(at index: Int) {
        service.command.accept(.delete(self.podcastsCache.value[0].items[index]))
    }

    func load() {
        service.command.accept(.refresh)
    }
}
