//
//  TimelineViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxSwift
import RxRelay
import RxDataSources

class ShowListViewModel {

    private static let sectionIdentifier = ""

    private(set) var podcasts: BehaviorRelay<[AnimatableSectionModel<String, Podcast>]> = BehaviorRelay(value: [
        .init(model: ShowListViewModel.sectionIdentifier, items: [])
    ])
    private let repository: PodcastRepository

    // MARK: - Initializer
    
    init(repository: PodcastRepository) {
        self.repository = repository
    }

    // MARK: - Methods

    func remove(at index: Int) {
        try! self.repository.remove(self.podcasts.value[0].items[index])

        var newValue = self.podcasts.value[0].items
        newValue.remove(at: index)
        self.podcasts.accept([
            .init(model: ShowListViewModel.sectionIdentifier, items: newValue)
        ])
    }

    func load(completion: @escaping (Bool) -> Void) {
        self.repository.fetchAll { [unowned self] result in
            switch result {
            case .success(let fetchedPodcasts):
                self.podcasts.accept([
                    .init(model: ShowListViewModel.sectionIdentifier, items: fetchedPodcasts)
                ])
                completion(true)
            case .failure(_): break
                completion(false)
            }
        }
    }

}

extension Podcast: IdentifiableType {

    // MARK: - IndetifiableType

    typealias Identity = URL

    var identity: URL {
        return self.show.feedUrl
    }
}
