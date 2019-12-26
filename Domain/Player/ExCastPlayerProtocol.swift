//
//  ExCastPlayerProtocol.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/09/14.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

public protocol ExCastPlayerProtocol: AnyObject {
    func prepareToPlay()

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

public protocol ExCastPlayerDelegate: AnyObject {
    func didFinishPrepare()

    func didChangePlayingState(to state: ExCastPlayerState)

    func didChangePlaybackRate(to rate: Double)

    func didSeek(to time: TimeInterval)

    func didChangePlaybackTime(to time: TimeInterval)
}
