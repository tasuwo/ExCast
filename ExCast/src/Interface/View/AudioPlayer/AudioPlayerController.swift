//
//  AudioPlayerController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import AVFoundation
import Foundation

protocol AudioPlayerControlCommands {
    func prepareToPlay()

    func play()

    func pause()

    func stop()

    func seek(to time: TimeInterval, _ completion: @escaping (Bool) -> Void)

    func skip(direction: AudioPlayer.SkipDirection, duration seconds: TimeInterval)

    var delegate: AudioPlayerDelegate? { get set }
}

protocol AudioPlayerDelegate {
    func didFinishPrepare()

    func didChangePlayingState(to state: AudioPlayer.PlayingState)

    func didChangePlaybackTime(to time: TimeInterval)
}

private var kAudioPlayerContext: UInt8 = 0

class AudioPlayer: NSObject {
    private let contentUrl: URL
    private var playerItem: AVPlayerItem!
    private var player: AVPlayer!
    private var timeObserverToken: Any?

    var delegate: AudioPlayerDelegate?

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
                self.delegate?.didFinishPrepare()
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
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        self.timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.delegate?.didChangePlaybackTime(to: CMTimeGetSeconds(time))
        }
    }

    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}

extension AudioPlayer: AudioPlayerControlCommands {

    // MARK: - AudioPlayerControlCommands

    func prepareToPlay() {
        DispatchQueue.global(qos: .background).async {
            let asset = AVAsset(url: self.contentUrl)
            self.playerItem = AVPlayerItem(asset: asset)

            asset.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.isPlayable)], completionHandler: { [weak self] in
                guard let self = self else { return }

                var error: NSError? = nil
                let status = asset.statusOfValue(forKey: #keyPath(AVAsset.isPlayable), error: &error)

                switch status {
                case .loaded:
                    DispatchQueue.main.async {
                        self.player = AVPlayer(playerItem: self.playerItem)
                        self.addPeriodicTimeObserver()
                        self.playerItem.addObserver(self,
                                                    forKeyPath: #keyPath(AVPlayerItem.status),
                                                    options: [.old, .new],
                                                    context: &kAudioPlayerContext)
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
        self.delegate?.didChangePlayingState(to: .playing)
    }

    func pause() {
        self.player.pause()
        self.delegate?.didChangePlayingState(to: .pause)
    }

    func stop() {
        // TODO:
    }

    func seek(to seconds: TimeInterval, _ completion: @escaping (Bool) -> Void) {
        let time = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 100)
        self.player.seek(to: time, completionHandler: completion)
    }

    func skip(direction: SkipDirection, duration seconds: TimeInterval) {
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
        player.seek(to: time)

        self.delegate?.didChangePlaybackTime(to: CMTimeGetSeconds(player.currentTime()))
    }

}

