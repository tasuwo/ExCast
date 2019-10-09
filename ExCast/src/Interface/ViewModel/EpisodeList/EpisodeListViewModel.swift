//
//  EpisodeListViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources
import RxRelay
import RxSwift

struct EpisodeListViewModel {
    private static let sectionIdentifier = ""

    private let feedUrl: URL
    private(set) var service: PodcastServiceProtocol

    private(set) var podcast: BehaviorRelay<Podcast>
    private(set) var episodes: BehaviorRelay<[AnimatableSectionModel<String, Podcast.Episode>]>

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(podcast: Podcast, service: PodcastServiceProtocol) {
        feedUrl = podcast.show.feedUrl
        self.service = service

        self.podcast = BehaviorRelay(value: podcast)
        episodes = BehaviorRelay(value: [
            .init(model: EpisodeListViewModel.sectionIdentifier, items: []),
        ])

        self.service.state
            .compactMap { state -> [Podcast]? in
                switch state {
                case let .content(podcasts):
                    return podcasts
                default:
                    return nil
                }
            }
            .subscribe { [self] event in
                switch event {
                case let .next(podcasts):
                    // TODO: 効率化
                    self.podcast.accept(podcasts.first(where: { $0.show.feedUrl == self.feedUrl })!)
                default: break
                }
            }
            .disposed(by: disposeBag)

        self.podcast
            .map { $0.episodes }
            .map { [.init(model: EpisodeListViewModel.sectionIdentifier, items: $0)] as [AnimatableSectionModel<String, Podcast.Episode>] }
            .bind(to: episodes)
            .disposed(by: disposeBag)
    }

    // MARK: - Methods

    func load() {
        DispatchQueue.global().async {
            self.service.command.accept(.refresh)
        }
    }
}

extension Podcast.Episode: IdentifiableType {
    // MARK: - IndetifiableType

    typealias Identity = String

    var identity: String {
        return title
    }
}
