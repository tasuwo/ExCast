//
//  Entity.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/12/08.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

public protocol Entity: Codable, Equatable {
    associatedtype Identity: Hashable

    var identity: Identity { get }
}
