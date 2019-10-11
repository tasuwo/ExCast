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
    private let service: PodcastServiceProtocol

    private(set) var podcast: BehaviorRelay<Podcast>
    private(set) var episodes: BehaviorRelay<[AnimatableSectionModel<String, Podcast.Episode>]>

    enum State {
        case normal
        case progress
        case error
    }
    private(set) var state: BehaviorRelay<State> = BehaviorRelay(value: .normal)

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

        self.service.state
            .map({ state -> State in
                switch state {
                case .content(_): return .normal
                case .error: return .error
                case .progress: return .progress
                }
            })
            .bind(to: self.state)
            .disposed(by: self.disposeBag)

        self.podcast
            .map { $0.episodes }
            .map { [.init(model: EpisodeListViewModel.sectionIdentifier, items: $0)] as [AnimatableSectionModel<String, Podcast.Episode>] }
            .bind(to: episodes)
            .disposed(by: disposeBag)
    }

    // MARK: - Methods

    func refresh() {
        self.service.command.accept(.refresh)
    }

    func fetch(url: URL) {
        self.service.command.accept(.fetch(url))
    }
}

extension Podcast.Episode: IdentifiableType {
    // MARK: - IndetifiableType

    typealias Identity = String

    var identity: String {
        return title
    }
}
