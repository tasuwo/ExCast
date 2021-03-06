//
//  PodcastRepositorySpec.swift
//  InfrastructureTests
//
//  Created by Tasuku Tozawa on 2019/12/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Nimble
import Quick
import RxBlocking

@testable import Infrastructure

class PodcastRepositorySpec: QuickSpec {
    private let queue = DispatchQueue(label: "net.tasuwo.ExCast.Infrastructure.PodcastRepositorySpec")

    override func spec() {
        let repository = PodcastRepository(queue: queue)

        describe("getAll") {
            context("Podcastがひとつもない") {
                beforeEach {
                    waitUntil(on: self.queue) { realm, done in
                        realm.deleteAll()
                        done()
                    }
                }

                it("空が返る") {
                    let results = try! repository.getAll().toBlocking().first()!

                    waitUntil(on: self.queue) { done in
                        expect(results).to(beEmpty())
                        done()
                    }
                }
            }

            context("Podcastが存在する") {
                let podcasts = [
                    Podcast.makeDefault(feedUrl: URL(string: "http://example.1.com")!, episodes: [
                        Episode.makeDefault(id: "1-1", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "1-2", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "1-3", meta: Item.makeDefault(), playback: nil),
                    ]),
                    Podcast.makeDefault(feedUrl: URL(string: "http://example.2.com")!, episodes: [
                        Episode.makeDefault(id: "2-1", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "2-2", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "2-3", meta: Item.makeDefault(), playback: nil),
                    ]),
                    Podcast.makeDefault(feedUrl: URL(string: "http://example.3.com")!, episodes: [
                        Episode.makeDefault(id: "3-1", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "3-2", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "3-3", meta: Item.makeDefault(), playback: nil),
                    ]),
                ]

                beforeEach {
                    waitUntil(on: self.queue) { realm, done in
                        realm.deleteAll()
                        realm.add(podcasts.map { $0.asManagedObject() })
                        done()
                    }
                }

                it("全て取得できる") {
                    let results = Array(try! repository.getAll().toBlocking().first()!)

                    waitUntil(on: self.queue) { done in
                        expect(results).to(equal(podcasts))
                        done()
                    }
                }
            }
        }

        describe("add") {
            let podcasts = [
                Podcast.makeDefault(feedUrl: URL(string: "http://example.1.com")!, episodes: [
                    Episode.makeDefault(id: "1-1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "1-2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "1-3", meta: Item.makeDefault(), playback: nil),
                ]),
                Podcast.makeDefault(feedUrl: URL(string: "http://example.2.com")!, episodes: [
                    Episode.makeDefault(id: "2-1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "2-2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "2-3", meta: Item.makeDefault(), playback: nil),
                ]),
            ]
            var addedPodcast: Podcast!

            beforeEach {
                waitUntil(on: self.queue) { realm, done in
                    realm.deleteAll()
                    realm.add(podcasts.map { $0.asManagedObject() })
                    done()
                }
            }

            context("存在していないfeedUrlのPodcastを追加する") {
                beforeEach {
                    addedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.3.com")!, episodes: [
                        Episode.makeDefault(id: "3-1", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "3-2", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "3-3", meta: Item.makeDefault(), playback: nil),
                    ])
                    _ = repository.add(addedPodcast).toBlocking().materialize()
                }

                it("正常に追加できる") {
                    waitUntil(on: self.queue) { realm, done in
                        let results = Array(realm.objects(PodcastObject.self)).map { Podcast.make(by: $0) }
                        expect(results.count).to(be(3))
                        expect(results[0]).to(equal(podcasts[0]))
                        expect(results[1]).to(equal(podcasts[1]))
                        expect(results[2]).to(equal(addedPodcast))
                        done()
                    }
                }
            }

            context("既に存在しているfeedUrlのPodcastを追加する") {
                beforeEach {
                    addedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.1.com")!, episodes: [
                        Episode.makeDefault(id: "999-1", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "999-2", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "999-3", meta: Item.makeDefault(), playback: nil),
                    ])
                    _ = repository.add(addedPodcast).toBlocking().materialize()
                }

                it("何も起きない") {
                    waitUntil(on: self.queue) { realm, done in
                        let results = Array(realm.objects(PodcastObject.self)).map { Podcast.make(by: $0) }
                        expect(results.count).to(be(2))
                        expect(results[0]).to(equal(podcasts[0]))
                        expect(results[1]).to(equal(podcasts[1]))
                        done()
                    }
                }
            }
        }

        describe("update") {
            let podcasts = [
                Podcast.makeDefault(feedUrl: URL(string: "http://example.1.com")!, episodes: [
                    Episode.makeDefault(id: "1-1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "1-2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "1-3", meta: Item.makeDefault(), playback: nil),
                ]),
                Podcast.makeDefault(feedUrl: URL(string: "http://example.2.com")!, episodes: [
                    Episode.makeDefault(id: "2-1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "2-2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "2-3", meta: Item.makeDefault(), playback: nil),
                ]),
                Podcast.makeDefault(feedUrl: URL(string: "http://example.3.com")!, episodes: [
                    Episode.makeDefault(id: "3-1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "3-2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "3-3", meta: Item.makeDefault(), playback: nil),
                ]),
            ]
            var updatedPodcast: Podcast!

            beforeEach {
                waitUntil(on: self.queue) { realm, done in
                    realm.deleteAll()
                    realm.add(podcasts.map { $0.asManagedObject() })
                    done()
                }
            }

            context("存在しているPodcastを更新する") {
                beforeEach {
                    waitUntil(on: self.queue) { realm, done in
                        realm.deleteAll()
                        realm.add(podcasts.map { $0.asManagedObject() })
                        done()
                    }
                }

                context("Episodeを追加") {
                    beforeEach {
                        updatedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.2.com")!, episodes: [
                            Episode.makeDefault(id: "2-1", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "2-2", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "2-3", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "2-4", meta: Item.makeDefault(), playback: nil),
                        ])
                        _ = repository.update(updatedPodcast).toBlocking().materialize()
                    }

                    it("データを更新する") {
                        waitUntil(on: self.queue) { realm, done in
                            let storedItems = realm.objects(PodcastObject.self)
                            expect(storedItems.count).to(be(3))
                            expect(Podcast.make(by: storedItems[0])).to(equal(podcasts[0]))
                            expect(Podcast.make(by: storedItems[1])).to(equal(updatedPodcast))
                            expect(Podcast.make(by: storedItems[2])).to(equal(podcasts[2]))
                            done()
                        }
                    }
                }

                context("Episodeを削除") {
                    beforeEach {
                        updatedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.2.com")!, episodes: [
                            Episode.makeDefault(id: "2-1", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "2-3", meta: Item.makeDefault(), playback: nil),
                        ])
                        _ = repository.update(updatedPodcast).toBlocking().materialize()
                    }

                    it("データを更新する") {
                        waitUntil(on: self.queue) { realm, done in
                            let storedItems = realm.objects(PodcastObject.self)
                            expect(storedItems.count).to(be(3))
                            expect(Podcast.make(by: storedItems[0])).to(equal(podcasts[0]))
                            expect(Podcast.make(by: storedItems[1])).to(equal(updatedPodcast))
                            expect(Podcast.make(by: storedItems[2])).to(equal(podcasts[2]))
                            done()
                        }
                    }
                }

                context("metaを編集する") {
                    beforeEach {
                        updatedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.2.com")!, episodes: [
                            Episode.makeDefault(id: "2-1", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "2-2", meta: Item.makeDefault(title: "TITLE"), playback: nil),
                            Episode.makeDefault(id: "2-3", meta: Item.makeDefault(), playback: nil),
                        ])
                        _ = repository.update(updatedPodcast).toBlocking().materialize()
                    }

                    it("データを更新する") {
                        waitUntil(on: self.queue) { realm, done in
                            let storedItems = realm.objects(PodcastObject.self)
                            expect(storedItems.count).to(be(3))
                            expect(Podcast.make(by: storedItems[0])).to(equal(podcasts[0]))
                            expect(Podcast.make(by: storedItems[1])).to(equal(updatedPodcast))
                            expect(Podcast.make(by: storedItems[2])).to(equal(podcasts[2]))
                            done()
                        }
                    }
                }
            }

            context("存在していないPodcastを更新する") {
                beforeEach {
                    updatedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.999.com")!, episodes: [
                        Episode.makeDefault(id: "999-1", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "999-2", meta: Item.makeDefault(title: "TITLE"), playback: nil),
                        Episode.makeDefault(id: "999-3", meta: Item.makeDefault(), playback: nil),
                    ])
                    _ = repository.update(updatedPodcast).toBlocking().materialize()
                }

                it("データを更新しない") {
                    waitUntil(on: self.queue) { realm, done in
                        let storedItems = realm.objects(PodcastObject.self)
                        expect(storedItems.count).to(be(3))
                        expect(Podcast.make(by: storedItems[0])).to(equal(podcasts[0]))
                        expect(Podcast.make(by: storedItems[1])).to(equal(podcasts[1]))
                        expect(Podcast.make(by: storedItems[2])).to(equal(podcasts[2]))
                        done()
                    }
                }
            }
        }

        describe("updateEpisodesMeta") {
            let playbacks = [
                Playback(playbackPositionSec: 10),
                Playback(playbackPositionSec: 100),
                Playback(playbackPositionSec: 1000),
            ]
            let podcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.com")!, episodes: [
                Episode.makeDefault(id: "1", meta: Item.makeDefault(), playback: playbacks[0]),
                Episode.makeDefault(id: "2", meta: Item.makeDefault(), playback: playbacks[1]),
                Episode.makeDefault(id: "3", meta: Item.makeDefault(), playback: playbacks[2]),
            ])

            var updatedPodcast: Podcast!

            beforeEach {
                waitUntil(on: self.queue) { realm, done in
                    realm.deleteAll()
                    realm.add(podcast.asManagedObject())
                    done()
                }
            }

            context("存在しているPodcastを更新する") {
                beforeEach {
                    waitUntil(on: self.queue) { realm, done in
                        realm.deleteAll()
                        realm.add(podcast.asManagedObject())
                        done()
                    }
                }

                context("Episodeを追加") {
                    beforeEach {
                        updatedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.com")!, episodes: [
                            Episode.makeDefault(id: "1", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "2", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "3", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "4", meta: Item.makeDefault(), playback: nil),
                        ])
                        _ = repository.updateEpisodesMeta(updatedPodcast).toBlocking().materialize()
                    }

                    it("データを更新が更新され、既存のEpisodeのplaybackが引き継がれる") {
                        waitUntil(on: self.queue) { realm, done in
                            let storedItems = realm.objects(PodcastObject.self)
                            expect(storedItems.count).to(equal(1))
                            expect(Podcast.make(by: storedItems[0]).meta).to(equal(podcast.meta))
                            expect(Podcast.make(by: storedItems[0]).episodes.count).to(equal(4))
                            expect(Podcast.make(by: storedItems[0]).episodes[0]).to(equal(podcast.episodes[0]))
                            expect(Podcast.make(by: storedItems[0]).episodes[1]).to(equal(podcast.episodes[1]))
                            expect(Podcast.make(by: storedItems[0]).episodes[2]).to(equal(podcast.episodes[2]))
                            expect(Podcast.make(by: storedItems[0]).episodes[3]).to(equal(updatedPodcast.episodes[3]))

                            let storedEpisodes = realm.objects(EpisodeObject.self)
                            expect(storedEpisodes.count).to(equal(4))

                            done()
                        }
                    }
                }

                context("Episodeを削除") {
                    beforeEach {
                        updatedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.com")!, episodes: [
                            Episode.makeDefault(id: "1", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "3", meta: Item.makeDefault(), playback: nil),
                        ])
                        _ = repository.updateEpisodesMeta(updatedPodcast).toBlocking().materialize()
                    }

                    it("データが削除され、既存のEpisodeのplaybackが引き継がれる") {
                        waitUntil(on: self.queue) { realm, done in
                            let storedItems = realm.objects(PodcastObject.self)
                            expect(storedItems.count).to(be(1))
                            expect(Podcast.make(by: storedItems[0]).meta).to(equal(podcast.meta))
                            expect(Podcast.make(by: storedItems[0]).episodes.count).to(equal(2))
                            expect(Podcast.make(by: storedItems[0]).episodes[0]).to(equal(podcast.episodes[0]))
                            expect(Podcast.make(by: storedItems[0]).episodes[1]).to(equal(podcast.episodes[2]))

                            let storedEpisodes = realm.objects(EpisodeObject.self)
                            expect(storedEpisodes.count).to(equal(2))

                            done()
                        }
                    }
                }

                context("metaを編集する") {
                    beforeEach {
                        updatedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.com")!, episodes: [
                            Episode.makeDefault(id: "1", meta: Item.makeDefault(), playback: nil),
                            Episode.makeDefault(id: "2", meta: Item.makeDefault(title: "TITLE"), playback: nil),
                            Episode.makeDefault(id: "3", meta: Item.makeDefault(), playback: nil),
                        ])
                        _ = repository.updateEpisodesMeta(updatedPodcast).toBlocking().materialize()
                    }

                    it("データが更新され、既存のEpisodeのplaybackが引き継がれる") {
                        waitUntil(on: self.queue) { realm, done in
                            let storedItems = realm.objects(PodcastObject.self)
                            expect(storedItems.count).to(equal(1))
                            expect(Podcast.make(by: storedItems[0]).meta).to(equal(podcast.meta))
                            expect(Podcast.make(by: storedItems[0]).episodes.count).to(equal(3))
                            expect(Podcast.make(by: storedItems[0]).episodes[0]).to(equal(podcast.episodes[0]))
                            expect(Podcast.make(by: storedItems[0]).episodes[1].meta).to(equal(updatedPodcast.episodes[1].meta))
                            expect(Podcast.make(by: storedItems[0]).episodes[1].playback).to(equal(podcast.episodes[1].playback))
                            expect(Podcast.make(by: storedItems[0]).episodes[2]).to(equal(podcast.episodes[2]))

                            let storedEpisodes = realm.objects(EpisodeObject.self)
                            expect(storedEpisodes.count).to(equal(3))

                            done()
                        }
                    }
                }
            }
        }

        describe("remove") {
            let podcasts = [
                Podcast.makeDefault(feedUrl: URL(string: "http://example.1.com")!, episodes: [
                    Episode.makeDefault(id: "1-1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "1-2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "1-3", meta: Item.makeDefault(), playback: nil),
                ]),
                Podcast.makeDefault(feedUrl: URL(string: "http://example.2.com")!, episodes: [
                    Episode.makeDefault(id: "2-1", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "2-2", meta: Item.makeDefault(), playback: nil),
                    Episode.makeDefault(id: "2-3", meta: Item.makeDefault(), playback: nil),
                ]),
            ]
            var deletedPodcast: Podcast!

            beforeEach {
                waitUntil(on: self.queue) { realm, done in
                    realm.deleteAll()
                    realm.add(podcasts.map { $0.asManagedObject() })
                    done()
                }
            }

            context("存在しているPodcastのfeedUrlを指定する") {
                beforeEach {
                    deletedPodcast = podcasts[0]
                    _ = repository.remove(deletedPodcast).toBlocking().materialize()
                }

                it("関連するデータを全て削除する") {
                    waitUntil(on: self.queue) { realm, done in
                        let storedItems = realm.objects(PodcastObject.self)
                        expect(storedItems.count).to(be(1))
                        expect(Podcast.make(by: storedItems[0])).to(equal(podcasts[1]))
                        done()
                    }
                }
            }

            context("存在していないPodcastのfeedUrlを指定する") {
                beforeEach {
                    deletedPodcast = Podcast.makeDefault(feedUrl: URL(string: "http://example.999.com")!, episodes: [
                        Episode.makeDefault(id: "999-1", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "999-2", meta: Item.makeDefault(), playback: nil),
                        Episode.makeDefault(id: "999-3", meta: Item.makeDefault(), playback: nil),
                    ])
                    _ = repository.remove(deletedPodcast).toBlocking().materialize()
                }

                it("関連するデータを全て削除する") {
                    waitUntil(on: self.queue) { realm, done in
                        let storedItems = realm.objects(PodcastObject.self)
                        expect(storedItems.count).to(be(2))
                        expect(Podcast.make(by: storedItems[0])).to(equal(podcasts[0]))
                        expect(Podcast.make(by: storedItems[1])).to(equal(podcasts[1]))
                        done()
                    }
                }
            }
        }
    }
}
