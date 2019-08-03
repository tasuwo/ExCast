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

    func add(_ podcast: Podcast) throws

    func update(_ podcast: Podcast) throws

    func remove(_ podcast: Podcast) throws

}
