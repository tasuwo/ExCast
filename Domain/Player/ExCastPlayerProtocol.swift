//
//  ExCastPlayerProtocol.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/09/14.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

/// @mockable
public protocol ExCastPlayerProtocol: AnyObject {
    var createdPlayer: BehaviorRelay<Bool> { get }

    func play()

    func pause()

    func seek(to time: TimeInterval, completion: @escaping (Bool) -> Void)

    func skipForward(duration seconds: TimeInterval, completion: @escaping (Bool) -> Void)

    func skipBackward(duration seconds: TimeInterval, completion: @escaping (Bool) -> Void)

    func register(delegate: ExCastPlayerDelegate)
}

public enum ExCastPlayerState {
    case playing
    case pause
    case finish
}

/// @mockable
public protocol ExCastPlayerDelegate: AnyObject {
    func didPrepare(duration: TimeInterval)

    func didChangePlayingState(to state: ExCastPlayerState)

    func didChangePlaybackRate(to rate: Double)

    func didSeek(to time: TimeInterval)

    func didChangePlaybackTime(to time: TimeInterval)
}
