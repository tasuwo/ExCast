//
//  EpisodeRepositorySpec.swift
//  InfrastructureTests
//
//  Created by Tasuku Tozawa on 2019/12/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Nimble
import Quick

import RealmSwift
import RxBlocking
import RxTest

@testable import Infrastructure

class EpisodeRepositorySpec: QuickSpec {
    private let queue = DispatchQueue(label: "net.tasuwo.ExCast.Infrastructure.EpisodeRepositorySpec")

    override func spec() {
        let repository = EpisodeRepository(queue: self.queue)

        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        }

        describe("getAll") {
            let url = URL(string: "http://example.com")!

            context("Podcastがひとつもない") {
                beforeEach {
                    waitUntil { done in
                        RealmTestHelper.deleteAllRealmObjects(queue: self.queue, done: done)
                    }
                }
                
                it("空が返る") {
                    let results = try! repository.getAll(url).toBlocking().first()!
                    waitUntil(on: self.queue) { done in
                        expect(results).to(beEmpty())
                        done()
                    }
                }
            }

            context("Podcastが存在する") {
                let episodes: [Episode] = [
                    Episode.makeDefault(id: "1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "3", meta: Item.makeDefault(), playback: nil)
                ]
                let podcast = Podcast.makeDefault(feedUrl: url, episodes: episodes)

                context("指定したfeedUrlを持つPodcastが存在する") {
                    beforeEach {
                        waitUntil(on: self.queue, with: try! Realm()) { realm, done in
                            realm.deleteAll()
                            realm.add(podcast.asManagedObject())
                            done()
                        }
                    }

                    it("全てのエピソードが取得できる") {
                        let results = try! repository.getAll(url).toBlocking().first()!
                        waitUntil(on: self.queue) { done in
                            expect(results).to(equal(episodes))
                            done()
                        }
                    }
                }

                context("指定したfeedUrlを持つPodcastが存在しない") {
                    beforeEach {
                        waitUntil(on: self.queue, with: try! Realm()) { realm, done in
                            realm.deleteAll()
                            realm.add(Podcast.makeDefault(feedUrl: URL(string: "http://dummy.example.com")!, episodes: episodes).asManagedObject())
                            done()
                        }
                    }

                    it("空が返る") {
                        let results = try! repository.getAll(url).toBlocking().first()!
                        waitUntil(on: self.queue) { done in
                            expect(results).to(beEmpty())
                            done()
                        }
                    }
                }
            }
        }
    }
}
