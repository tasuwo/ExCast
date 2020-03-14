//
//  Copyright © 2020 Tasuku Tozawa. All rights reserved.
//

import Nimble
import Quick
import RxBlocking
import RxSwift
import RxTest
import SharedTestHelper

@testable import Domain
@testable import Infrastructure

class PodcastGatewaySpec: QuickSpec {
    override func spec() {
        let disposeBag = DisposeBag()

        /*
         * Mock/Stubs
         */

        var gateway: PodcastGateway!
        var scheduler: TestScheduler!

        /*
         * Dummy requests
         */

        let feedUrl = URL(string: "https://example.com")!
        let data = "dummy data".data(using: .utf8)

        /*
         * Dummy responses
         */

        let successResponse = HTTPURLResponse(url: feedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let failureResponse = HTTPURLResponse(url: feedUrl, statusCode: 503, httpVersion: nil, headerFields: nil)!
        let fetchedPodcast = Podcast(feedUrl: feedUrl, meta: .makeDefault(), episodes: [.makeDefault()])

        beforeEach {
            gateway = PodcastGateway(session: URLSessionMock.mock,
                                     factory: PodcastFactoryProtocolMock.self)
            scheduler = TestScheduler(initialClock: 0)
        }

        afterEach {
            PodcastFactoryProtocolMock.makeHandler = nil
            PodcastFactoryProtocolMock.makeCallCount = 0
        }

        describe("fetch(feed:)") {
            context("通信に成功する") {
                context("Podcastのパースに成功する") {
                    beforeEach {
                        URLProtocolMock.handler = { request in
                            expect(request.url).to(equal(feedUrl))

                            return (successResponse, data)
                        }
                        PodcastFactoryProtocolMock.makeHandler = { source in
                            expect(source).to(equal(data))

                            return fetchedPodcast
                        }

                        scheduler
                            .createHotObservable([
                                Recorded.next(100, PodcastGatewayCommand.fetch(feedUrl)),
                            ])
                            .bind(to: gateway.command)
                            .disposed(by: disposeBag)
                    }

                    it("progressになった後にcontentが取得できる") {
                        let observer = scheduler.createObserver(PodcastGatewayQuery.self)
                        gateway.state
                            .bind(to: observer)
                            .disposed(by: disposeBag)
                        scheduler.start()

                        expect(observer.events).to(equal([
                            Recorded.next(0, .content(nil)),
                            Recorded.next(100, .progress),
                        ]))
                        expect(observer.events.last!.value.element!)
                            .toEventually(equal(.content(fetchedPodcast)))

                        expect(PodcastFactoryProtocolMock.makeCallCount).to(equal(1))
                    }
                }

                context("Podcastのパースに失敗する") {
                    beforeEach {
                        URLProtocolMock.handler = { _ in return (successResponse, data) }
                        PodcastFactoryProtocolMock.makeHandler = { _ in return nil }

                        scheduler
                            .createHotObservable([
                                Recorded.next(100, PodcastGatewayCommand.fetch(feedUrl)),
                            ])
                            .bind(to: gateway.command)
                            .disposed(by: disposeBag)
                    }

                    it("progressになった後にerrorとなる") {
                        let observer = scheduler.createObserver(PodcastGatewayQuery.self)
                        gateway.state
                            .bind(to: observer)
                            .disposed(by: disposeBag)
                        scheduler.start()

                        expect(observer.events).to(equal([
                            Recorded.next(0, .content(nil)),
                            Recorded.next(100, .progress),
                        ]))
                        expect(observer.events.last!.value.element!)
                            .toEventually(equal(.error))

                        expect(PodcastFactoryProtocolMock.makeCallCount).to(equal(1))
                    }
                }
            }

            context("通信に失敗する") {
                context("statusCodeが2XXではない") {
                    beforeEach {
                        URLProtocolMock.handler = { _ in return (failureResponse, data) }
                        PodcastFactoryProtocolMock.makeHandler = { _ in return nil }

                        scheduler
                            .createHotObservable([
                                Recorded.next(100, PodcastGatewayCommand.fetch(feedUrl)),
                            ])
                            .bind(to: gateway.command)
                            .disposed(by: disposeBag)
                    }

                    it("progressになった後にerrorとなる") {
                        let observer = scheduler.createObserver(PodcastGatewayQuery.self)
                        gateway.state
                            .bind(to: observer)
                            .disposed(by: disposeBag)
                        scheduler.start()

                        expect(observer.events).to(equal([
                            Recorded.next(0, .content(nil)),
                            Recorded.next(100, .progress),
                        ]))
                        expect(observer.events.last!.value.element!)
                            .toEventually(equal(.error))

                        expect(PodcastFactoryProtocolMock.makeCallCount).to(equal(0))
                    }
                }

                context("通信エラーが発生した") {
                    beforeEach {
                        URLProtocolMock.handler = { _ in throw NSError(domain: "", code: 0, userInfo: nil) }
                        PodcastFactoryProtocolMock.makeHandler = { _ in return nil }

                        scheduler
                            .createHotObservable([
                                Recorded.next(100, PodcastGatewayCommand.fetch(feedUrl)),
                            ])
                            .bind(to: gateway.command)
                            .disposed(by: disposeBag)
                    }

                    it("progressになった後にerrorとなる") {
                        let observer = scheduler.createObserver(PodcastGatewayQuery.self)
                        gateway.state
                            .bind(to: observer)
                            .disposed(by: disposeBag)
                        scheduler.start()

                        expect(observer.events).to(equal([
                            Recorded.next(0, .content(nil)),
                            Recorded.next(100, .progress),
                        ]))
                        expect(observer.events.last!.value.element!)
                            .toEventually(equal(.error))

                        expect(PodcastFactoryProtocolMock.makeCallCount).to(equal(0))
                    }
                }
            }
        }
    }
}
