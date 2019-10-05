//
//  EpisodeListViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxSwift
import RxRelay
import RxDataSources

class EpisodeListViewModel {

    private static let sectionIdentifier = ""

    private let feedUrl: URL
    private(set) var show: BehaviorRelay<Podcast.Show>
    private(set) var episodes: BehaviorRelay<[AnimatableSectionModel<String, Podcast.Episode>]>
    private(set) var playingEpisode: BehaviorSubject<Podcast.Episode?> = BehaviorSubject(value: nil)

    private let gateway: PodcastGateway

    // MARK: - Initializer

    init(podcast: Podcast, gateway: PodcastGateway) {
        self.feedUrl = podcast.show.feedUrl
        self.show = BehaviorRelay(value: podcast.show)
        self.episodes = BehaviorRelay(value: [
            .init(model: EpisodeListViewModel.sectionIdentifier, items: [])
        ])
        self.gateway = gateway
    }

    // MARK: - Methods

    func load(completion: @escaping (Bool) -> Void) {
        self.gateway.fetch(feed: self.feedUrl) { [unowned self] result in
            switch result {
            case .success(let fetchedPodcast):
                self.show.accept(fetchedPodcast.show)
                self.episodes.accept([
                    .init(model: EpisodeListViewModel.sectionIdentifier, items: fetchedPodcast.episodes)
                ])
                completion(true)
            case .failure(_):
                completion(false)
                break
            }
        }
    }

}

extension Podcast.Episode: IdentifiableType {

    // MARK: - IndetifiableType

    typealias Identity = String

    var identity: String {
        return self.title
    }
}
