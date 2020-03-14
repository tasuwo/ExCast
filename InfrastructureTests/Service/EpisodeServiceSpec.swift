//
//  Copyright © 2020 Tasuku Tozawa. All rights reserved.
//

import Nimble
import Quick
import RxBlocking
import RxSwift
import RxTest

@testable import Domain
@testable import Infrastructure
@testable import SharedTestHelper

class EpisodeServiceSpec: QuickSpec {
    override func spec() {
        let disposeBag = DisposeBag()

        /*
         * Mock/Stubs
         */

        var service: EpisodeService!
        var gateway: PodcastGatewayProtocolMock!
        var podcastRepository: PodcastRepositoryProtocolMock!
        var episodeRepository: EpisodeRepositoryProtocolMock!
        var scheduler: TestScheduler!

        /*
         * Dummy requests
         */

        let feedUrl = URL(string: "https://example.com")!

        /*
         * Dummy responses
         */

        let fetchedEpisodes: [Episode] = [
            .makeDefault(id: "id1"),
            .makeDefault(id: "id2"),
            .makeDefault(id: "id3"),
        ]
        let fetchedPodcast: Podcast = .makeDefault(feedUrl: feedUrl, meta: .makeDefault(), episodes: fetchedEpisodes)

        beforeEach {
            podcastRepository = PodcastRepositoryProtocolMock()
            episodeRepository = EpisodeRepositoryProtocolMock()
            gateway = PodcastGatewayProtocolMock()

            gateway.underlyingState = .init(value: .content(nil))
            gateway.underlyingCommand = .init()

            service = EpisodeService(podcastRepository: podcastRepository,
                                     episodeRepository: episodeRepository,
                                     gateway: gateway)
            scheduler = TestScheduler(initialClock: 0)
        }

        describe("init") {
            it("notLoadedに初期化される") {
                expect(service.state.value).to(equal(.notLoaded))
            }
        }

        describe("clear") {
            // TODO:
        }

        describe("refresh") {
            context("取得に成功する") {
                beforeEach {
                    episodeRepository.getAllHandler = { url in
                        expect(url).to(equal(feedUrl))

                        return Observable.of(fetchedEpisodes).asSingle()
                    }

                    scheduler
                        .createHotObservable([
                            Recorded.next(100, EpisodeServiceCommand.refresh(feedUrl)),
                        ])
                        .bind(to: service.command)
                        .disposed(by: disposeBag)
                }

                it("progressになった後にcontentが取得できる") {
                    let observer = scheduler.createObserver(EpisodeServiceQuery.self)
                    service.state
                        .bind(to: observer)
                        .disposed(by: disposeBag)
                    scheduler.start()

                    expect(observer.events).to(equal([
                        Recorded.next(0, .notLoaded),
                        Recorded.next(100, .progress),
                    ]))
                    expect(observer.events.last!.value.element!)
                        .toEventually(equal(.content(feedUrl, fetchedEpisodes)))

                    expect(episodeRepository.getAllCallCount).to(equal(1))
                }
            }

            context("取得に失敗する") {
                beforeEach {
                    episodeRepository.getAllHandler = { _ in
                        return Single<[Episode]>.create { observer in
                            observer(.error(NSError(domain: "", code: 0, userInfo: nil)))
                            return Disposables.create()
                        }
                    }

                    scheduler
                        .createHotObservable([
                            Recorded.next(100, EpisodeServiceCommand.refresh(feedUrl)),
                        ])
                        .bind(to: service.command)
                        .disposed(by: disposeBag)
                }

                it("progressになった後にerrorとなる") {
                    let observer = scheduler.createObserver(EpisodeServiceQuery.self)
                    service.state
                        .bind(to: observer)
                        .disposed(by: disposeBag)
                    scheduler.start()

                    expect(observer.events).to(equal([
                        Recorded.next(0, .notLoaded),
                        Recorded.next(100, .progress),
                    ]))
                    expect(observer.events.last!.value.element!)
                        .toEventually(equal(.error))

                    expect(episodeRepository.getAllCallCount).to(equal(1))
                }
            }
        }

        describe("fetch") {
            context("取得に成功する") {
                beforeEach {
                    episodeRepository.getAllHandler = { url in
                        expect(url).to(equal(feedUrl))

                        return Observable.of(fetchedEpisodes).asSingle()
                    }
                    podcastRepository.updateEpisodesMetaHandler = { podcast in
                        expect(podcast).to(equal(fetchedPodcast))

                        return Completable.create { observer in
                            observer(.completed)
                            return Disposables.create()
                        }
                    }

                    scheduler
                        .createHotObservable([
                            Recorded.next(100, EpisodeServiceCommand.fetch(feedUrl)),
                        ])
                        .bind(to: service.command)
                        .disposed(by: disposeBag)

                    scheduler
                        .createHotObservable([
                            Recorded.next(500, PodcastGatewayQuery.content(fetchedPodcast)),
                        ])
                        .bind(to: gateway.state)
                        .disposed(by: disposeBag)
                }

                it("progressになった後にcontentが取得できる") {
                    let episodeServiceObserver = scheduler.createObserver(EpisodeServiceQuery.self)
                    service.state
                        .bind(to: episodeServiceObserver)
                        .disposed(by: disposeBag)

                    let gatewayObserver = scheduler.createObserver(PodcastGatewayCommand.self)
                    gateway.command
                        .bind(to: gatewayObserver)
                        .disposed(by: disposeBag)

                    scheduler.start()

                    expect(episodeServiceObserver.events).to(equal([
                        Recorded.next(0, .notLoaded),
                        Recorded.next(100, .progress),
                    ]))

                    // gatewayにfetchが要求される
                    expect(gatewayObserver.events.last!.value.element!)
                        .toEventually(equal(.fetch(feedUrl)))

                    // gatewayからfetch結果を取得する
                    expect(episodeServiceObserver.events.last!.value.element!)
                        .toEventually(equal(.content(feedUrl, fetchedEpisodes)))

                    // gatewayからのfetch結果による更新と、全件取得が行われる
                    expect(podcastRepository.updateEpisodesMetaCallCount).to(equal(1))
                    expect(episodeRepository.getAllCallCount).to(equal(1))
                }
            }

            context("取得に失敗する") {
                // TODO:
            }
        }

        describe("update") {
            // TODO:
        }
    }
}
