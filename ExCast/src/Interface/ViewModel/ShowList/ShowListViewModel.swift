//
//  TimelineViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources
import RxRelay
import RxSwift

class ShowListViewModel {
    private static let sectionIdentifier = ""

    private(set) var podcasts: BehaviorRelay<[AnimatableSectionModel<String, Podcast>]> = BehaviorRelay(value: [
        .init(model: ShowListViewModel.sectionIdentifier, items: []),
    ])

    private let service: PodcastServiceProtocol
    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(service: PodcastServiceProtocol) {
        self.service = service
        self.service.command.accept(.refresh)

        self.service.state
            .compactMap { state -> [Podcast]? in
                switch state {
                case let .content(podcasts):
                    return podcasts
                default:
                    return nil
                }
            }
            .map { [.init(model: ShowListViewModel.sectionIdentifier, items: $0)] as [AnimatableSectionModel<String, Podcast>] }
            .bind(to: podcasts)
            .disposed(by: disposeBag)
    }

    // MARK: - Methods

    func remove(at index: Int) {
        self.service.command.accept(.delete(self.podcasts.value[0].items[index]))
    }

    func load() {
        self.service.command.accept(.refresh)
    }
}
