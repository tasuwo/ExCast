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
import RxBlocking

@testable import Infrastructure

class EpisodeRepositorySpec: QuickSpec {
    private let queue = DispatchQueue(label: "net.tasuwo.ExCast.Infrastructure.EpisodeRepositorySpec")

    override func spec() {
        let repository = EpisodeRepository(queue: self.queue)

        describe("getAll") {
            context("Podcastがひとつもない") {
                beforeEach {
                    waitUntil(on: self.queue) { realm, done in
                        realm.deleteAll()
                        done()
                    }
                }

                it("空が返る") {
                    let results = try! repository.getAll(URL(string: "http://example.com")!).toBlocking().first()!

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
                    Episode.makeDefault(id: "3", meta: Item.makeDefault(), playback: nil),
                ]
                let podcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.com")!, episodes: episodes)
                var feedUrl: URL!

                beforeEach {
                    waitUntil(on: self.queue) { realm, done in
                        realm.deleteAll()
                        realm.add(podcast.asManagedObject())
                        done()
                    }
                }

                context("指定したfeedUrlを持つPodcastが存在する") {
                    beforeEach {
                        feedUrl = URL(string: "http://example.com")
                    }

                    it("全てのエピソードが取得できる") {
                        let results = try! repository.getAll(feedUrl).toBlocking().first()!

                        waitUntil(on: self.queue) { done in
                            expect(results).to(equal(episodes))
                            done()
                        }
                    }
                }

                context("指定したfeedUrlを持つPodcastが存在しない") {
                    beforeEach {
                        feedUrl = URL(string: "http://example.dummy.com")
                    }

                    it("空が返る") {
                        let results = try! repository.getAll(feedUrl).toBlocking().first()!

                        waitUntil(on: self.queue) { done in
                            expect(results).to(beEmpty())
                            done()
                        }
                    }
                }
            }
        }

        describe("update") {
            let url = URL(string: "http://example.com")!
            let episodes: [Episode] = [
                Episode.makeDefault(id: "1", meta: Item.makeDefault(), playback: nil),
                Episode.makeDefault(id: "2", meta: Item.makeDefault(), playback: nil),
                Episode.makeDefault(id: "3", meta: Item.makeDefault(), playback: nil),
            ]
            let podcast = Podcast.makeDefault(feedUrl: url, episodes: episodes)
            var updatedEpisode: Episode!

            beforeEach {
                waitUntil(on: self.queue) { realm, done in
                    realm.deleteAll()
                    realm.add(podcast.asManagedObject())
                    done()
                }
            }

            context("更新対象が存在する") {
                beforeEach {
                    updatedEpisode = Episode.makeDefault(id: "2", meta: Item.makeDefault(), playback: Playback.makeDefault(playbackPositionSec: 999))
                }

                it("データが更新される") {
                    _ = repository.update(updatedEpisode).toBlocking().materialize()

                    waitUntil(on: self.queue) { realm, done in
                        let storedEpisodes = realm.objects(EpisodeObject.self)
                        expect(Episode.make(by: storedEpisodes[0])).to(equal(episodes[0]))
                        expect(Episode.make(by: storedEpisodes[1])).to(equal(updatedEpisode))
                        expect(Episode.make(by: storedEpisodes[2])).to(equal(episodes[2]))
                        done()
                    }
                }
            }

            context("更新対象が存在しない") {
                beforeEach {
                    updatedEpisode = Episode.makeDefault(id: "999", meta: Item.makeDefault(), playback: Playback.makeDefault(playbackPositionSec: 999))
                }

                it("データが更新されない") {
                    _ = repository.update(updatedEpisode).toBlocking().materialize()

                    waitUntil(on: self.queue) { realm, done in
                        let storedPodcast = realm.objects(PodcastObject.self).first!
                        expect(Podcast.make(by: storedPodcast)).to(equal(podcast))
                        done()
                    }
                }
            }
        }
    }
}
