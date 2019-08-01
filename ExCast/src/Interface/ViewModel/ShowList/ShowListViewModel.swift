//
//  TimelineViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class ShowListViewModel {
    private let repository: PodcastRepository

    var podcasts: DynamicArray<Podcast>
    private var showsBond: ArrayBond<Podcast>!

    // MARK: - Initializer
    
    init(repository: PodcastRepository) {
        self.repository = repository
        self.podcasts = DynamicArray([])
    }

    // MARK: - Methods

    func setup() {
        self.showsBond = ArrayBond<Podcast>(insert: { [unowned self] tuples in
            tuples.forEach { [unowned self] tuple in
                self.repository.insertShow(at: tuple.0, tuple.1.show)
            }
        }, remove: { [unowned self] tuples  in
            let indicis = tuples.map { $0.0 }
            indicis.forEach { [unowned self] idx in
                self.repository.removeShow(at: idx)
            }
        }, update: { [unowned self] tuples in
            tuples.forEach { [unowned self] tuple in
                self.repository.updateShow(at: tuple.0, tuple.1.show)
            }
        })
    }

    func loadIfNeeded() {
        self.showsBond.release(self.podcasts)

        self.repository.fetchAll { [unowned self] result in
            defer {
                self.showsBond.bind(self.podcasts)
            }

            switch result {
            case .success(let fetchedPodcasts):
                let oldPodcasts = self.podcasts.values
                guard fetchedPodcasts != oldPodcasts else { return }
                self.podcasts.set(fetchedPodcasts)
            case .failure(_): break
                // TODO: Error handling
            }
        }
    }

}
