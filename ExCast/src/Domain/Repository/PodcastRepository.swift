//
//  PodcastRepository.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

protocol PodcastRepository {

    func fetchAll(_ completion: @escaping (Result<[Podcast], Error>) -> Void)

    func fetch(feed: URL, _ completion: @escaping (Result<Podcast, Error>) -> Void)

    func insertIfNeeded(_ podcast: Podcast)

    func insertShow(at index: Int, _ value: Podcast.Show)

    func updateShow(at index: Int, _ value: Podcast.Show)

    func removeShow(at index: Int)

}
