//
//  Command.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxSwift
import RxRelay

enum Query<T> {
    case progress
    case error
    case content(Array<T>)
}

enum Command<T> {
    case refresh
    case create(T)
    case delete(T)
}

protocol Service {
    associatedtype Item
    var state: BehaviorRelay<Query<Item>> { get }
    var command: PublishRelay<Command<Item>> { get set }
}
