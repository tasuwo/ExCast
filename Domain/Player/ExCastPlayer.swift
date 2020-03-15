//
//  ExCastPlayer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import AVFoundation
import RxRelay
import RxSwift

private var kAudioPlayerContext: UInt8 = 0

private class DelegateWrapper {
    weak var delegate: ExCastPlayerDelegate?

    init(_ delegate: ExCastPlayerDelegate) {
        self.delegate = delegate
    }
}

public class ExCastPlayer: NSObject {
    private var _isCreatedPlayer: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var player: AVPlayer!
    private let playerItem: AVPlayerItem

    private var timeObserverToken: Any?
    fileprivate var delegates: [DelegateWrapper] = []

    // MARK: - Lifecycle

    public init(contentUrl: URL, playImmediatedly: Bool, initialPlaybackPositionSec: Double) {
        let asset = AVAsset(url: contentUrl)
        self.playerItem = AVPlayerItem(asset: asset)
        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption(notification:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)

        asset.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.isPlayable)]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: #keyPath(AVAsset.isPlayable), error: &error)
            switch status {
            case .loaded:
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    // NOTE: AVPlayerItemに事前に設定
                    let duration = CMTimeMakeWithSeconds(Float64(initialPlaybackPositionSec), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                    self.playerItem.seek(to: duration, completionHandler: nil)

                    self.player = AVPlayer(playerItem: self.playerItem)
                    self.player.automaticallyWaitsToMinimizeStalling = false
                    if playImmediatedly {
                        self.player.playImmediately(atRate: 1)
                    }

                    self.addPeriodicTimeObserver()

                    self.playerItem.addObserver(self,
                                                forKeyPath: #keyPath(AVPlayerItem.status),
                                                options: [.old, .new],
                                                context: &kAudioPlayerContext)

                    self.createdPlayer.accept(true)
                }

            default:
                break
                // TODO:
            }
        }
    }

    deinit {
        // HACK: addObserver される前に removeObserver してしまうとクラッシュするので、player が生成されている場合のみ removeObserver する
        if self.createdPlayer.value {
            self.playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        }
        self.removePeriodicTimeObserver()
    }

    // MARK: - Private Methods

    @objc
    private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            self.delegates.forEach {
                $0.delegate?.didChangePlayingState(to: .pause)
                $0.delegate?.didChangePlaybackRate(to: 0)
            }

        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                self.play()
            }
        default: ()
        }
    }

    private func addPeriodicTimeObserver() {
        let time = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        self.timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
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

    // MARK: - NSObject (override)

    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard context == &kAudioPlayerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status

            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue) ?? .unknown
            } else {
                status = .unknown
            }

            switch status {
            case .readyToPlay:
                self.delegates.forEach { $0.delegate?.didPrepare(duration: self.playerItem.duration.seconds) }

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
}

extension ExCastPlayer: ExCastPlayerProtocol {
    // MARK: - ExCastPlayerProtocol

    public var createdPlayer: BehaviorRelay<Bool> {
        self._isCreatedPlayer
    }

    public func play() {
        player.play()
        delegates.forEach {
            $0.delegate?.didChangePlayingState(to: .playing)
            $0.delegate?.didChangePlaybackRate(to: 1)
        }
    }

    public func pause() {
        player.pause()
        delegates.forEach {
            $0.delegate?.didChangePlayingState(to: .pause)
            $0.delegate?.didChangePlaybackRate(to: 0)
        }
    }

    public func seek(to seconds: TimeInterval, completion: @escaping (Bool) -> Void) {
        let time = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 100)
        seekInternalPlayer(to: time, completion: completion)
    }

    public func skipForward(duration seconds: TimeInterval, completion: @escaping (Bool) -> Void) {
        let duration = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 100)
        let targetTimePoint = player.currentTime() + duration

        guard targetTimePoint <= playerItem.duration else {
            completion(false)
            return
        }

        seekInternalPlayer(to: targetTimePoint, completion: completion)
    }

    public func skipBackward(duration seconds: TimeInterval, completion: @escaping (Bool) -> Void) {
        let duration = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 100)
        let targetTimePoint = player.currentTime() - duration

        guard targetTimePoint >= CMTime.zero else {
            completion(false)
            return
        }

        seekInternalPlayer(to: targetTimePoint, completion: completion)
    }

    private func seekInternalPlayer(to time: CMTime, completion: @escaping (Bool) -> Void) {
        player.seek(to: time) { [weak self] seeked in
            guard let self = self else { return }

            if seeked {
                self.delegates.forEach {
                    $0.delegate?.didSeek(to: CMTimeGetSeconds(self.player.currentTime()))
                }
            }

            completion(seeked)
        }
    }

    public func register(delegate: ExCastPlayerDelegate) {
        delegates.append(DelegateWrapper(delegate))
    }
}
