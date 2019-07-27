//
//  AudioPlayerController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import AVFoundation

protocol AudioPlayerControlCommands: AnyObject {
    func prepareToPlay()

    func play()

    func pause()

    func stop()

    func seek(to time: TimeInterval, _ completion: @escaping (Bool) -> Void)

    func skip(direction: AudioPlayer.SkipDirection, duration seconds: TimeInterval, _ completion: @escaping (Bool) -> Void)

    func add(delegate: AudioPlayerDelegate)
}

protocol AudioPlayerDelegate: AnyObject {
    func didFinishPrepare()

    func didChangePlayingState(to state: AudioPlayer.PlayingState)

    func didChangePlaybackTime(to time: TimeInterval)
}

private var kAudioPlayerContext: UInt8 = 0

fileprivate class DelegateWrapper {
    weak var delegate: AudioPlayerDelegate?
    init(_ d: AudioPlayerDelegate) { delegate = d }
}

class AudioPlayer: NSObject {
    private let contentUrl: URL
    private weak var playerItem: AVPlayerItem!
    private var player: AVPlayer!
    private var timeObserverToken: Any?

    fileprivate var delegates: [DelegateWrapper] = []

    enum PlayingState {
        case playing
        case pause
        case finish
    }

    enum SkipDirection {
        case forward
        case backward
    }

    // MARK: - Lifecycle

    init(_ contentUrl: URL) {
        self.contentUrl = contentUrl
    }

    deinit {
        if let player = self.player {
            player.pause()
        }
        self.playerItem = nil
        self.player = nil
    }

    // MARK: - Methods

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard context == &kAudioPlayerContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status

            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            switch status {
            case .readyToPlay:
                self.delegates.forEach { $0.delegate?.didFinishPrepare() }
            case .failed:
                // TODO:
                break
            case .unknown:
                break
            default:
                break
            }
        }
    }

    private func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)

        self.timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.delegates.forEach { $0.delegate?.didChangePlaybackTime(to: time.seconds) }
        }
    }

    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}

// TODO: player.rate を見て失敗を通知する
extension AudioPlayer: AudioPlayerControlCommands {

    // MARK: - AudioPlayerControlCommands

    func prepareToPlay() {
        DispatchQueue.global(qos: .background).async {
            let asset = AVAsset(url: self.contentUrl)

            asset.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.isPlayable)], completionHandler: { [weak self] in
                guard let self = self else { return }

                var error: NSError? = nil
                let status = asset.statusOfValue(forKey: #keyPath(AVAsset.isPlayable), error: &error)
                let playerItem = AVPlayerItem(asset: asset)

                switch status {
                case .loaded:
                    DispatchQueue.main.async {
                        self.player = AVPlayer(playerItem: playerItem)
                        self.addPeriodicTimeObserver()
                        playerItem.addObserver(self,
                                                    forKeyPath: #keyPath(AVPlayerItem.status),
                                                    options: [.old, .new],
                                                    context: &kAudioPlayerContext)
                        self.playerItem = playerItem
                    }
                case .failed:
                    // TODO:
                    break
                case .cancelled:
                    // TODO:
                    break
                default:
                    // TODO:
                    break
                }
            })
        }
    }

    func play() {
        self.player.play()
        self.delegates.forEach { $0.delegate?.didChangePlayingState(to: .playing) }
    }

    func pause() {
        self.player.pause()
        self.delegates.forEach { $0.delegate?.didChangePlayingState(to: .pause) }
    }

    func stop() {
        // TODO:
    }

    func seek(to seconds: TimeInterval, _ completion: @escaping (Bool) -> Void) {
        let time = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 100)
        self.player.seek(to: time, completionHandler: completion)
    }

    func skip(direction: SkipDirection, duration seconds: TimeInterval, _ completion: @escaping (Bool) -> Void) {
        let duration = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 100)

        let time: CMTime
        switch direction {
        case .backward:
            let tmp = player.currentTime() - duration
            time = tmp < CMTime.zero ? CMTime.zero : tmp
        case .forward:
            let tmp = player.currentTime() + duration
            time = tmp > playerItem.duration ? playerItem.duration : tmp
        }
        self.player.seek(to: time, completionHandler: completion)

        self.delegates.forEach { $0.delegate?.didChangePlaybackTime(to: CMTimeGetSeconds(player.currentTime())) }
    }

    func add(delegate: AudioPlayerDelegate) {
        self.delegates.append(DelegateWrapper(delegate))
    }

}

