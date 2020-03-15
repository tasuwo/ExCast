//
//  EpisodePlayerControllerViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation
import MediaPlayer
import RxRelay
import RxSwift

class PlayerControllerViewModel {
    private let show: Show
    private let episode: Episode
    private var player: ExCastPlayerProtocol?
    private let configuration: PlayerConfiguration
    private let remoteCommands: RemoteCommandHandlerProtocol
    private let episodeService: EpisodeServiceProtocol

    private var playedAfterLoadingOnce: Bool = false

    private(set) var createdPlayer: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var isPlaying: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var isPrepared: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var duration: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var currentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var currentRate: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var displayCurrentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var isSliderGrabbed: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private var preventToSyncTime: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    var disposeBag = DisposeBag()

    let initialPlaybackSec: Double?

    // MARK: - Lifecycle

    init(show: Show, episode: Episode, playbackSec: Double?, remoteCommands: RemoteCommandHandlerProtocol, configuration: PlayerConfiguration, episodeService: EpisodeServiceProtocol) {
        self.show = show
        self.episode = episode
        self.remoteCommands = remoteCommands
        self.configuration = configuration
        self.duration.accept(episode.meta.duration ?? 0)
        self.episodeService = episodeService
        self.initialPlaybackSec = playbackSec

        self.currentTime
            .filter { [weak self] _ in self?.preventToSyncTime.value == false }
            .bind(to: displayCurrentTime)
            .disposed(by: disposeBag)

        self.isSliderGrabbed
            .filter { [weak self] _ in self?.isPrepared.value ?? false }
            .bind(onNext: { [weak self] grabbed in
                guard let self = self else { return }
                if grabbed {
                    self.preventToSyncTime.accept(true)
                } else {
                    self.player?.seek(to: self.displayCurrentTime.value) { isSucceeded in
                        guard isSucceeded else { return }
                        self.displayCurrentTime.accept(self.currentTime.value)
                        self.preventToSyncTime.accept(false)
                    }
                }
            })
            .disposed(by: disposeBag)

        self.currentTime
            .bind(onNext: { [weak self] time in
                guard let self = self else { return }
                self.episodeService.command.accept(.update(self.episode.identity, .init(playbackPositionSec: Int(time))))
            })
            .disposed(by: disposeBag)

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            self.player = ExCastPlayer(
                contentUrl: self.episode.meta.enclosure.url,
                playImmediatedly: true,
                // 指定された再生位置から再生を開始する
                initialPlaybackPositionSec: self.initialPlaybackSec ?? 0
            )
            self.player?.register(delegate: self)
            if let player = self.player {
                self.remoteCommands.register(delegate: player)
            }

            self.player?.createdPlayer
                .bind(to: self.createdPlayer)
                .disposed(by: self.disposeBag)
        }
    }

    // MARK: - Methods

    func playback() {
        if isPlaying.value {
            player?.pause()
        } else {
            player?.play()
        }
    }

    func skipForward() {
        player?.skipForward(duration: configuration.forwardSkipTime) { _ in }
    }

    func skipBackward() {
        player?.skipBackward(duration: configuration.backwardSkipTime) { _ in }
    }
}

extension PlayerControllerViewModel: ExCastPlayerDelegate {
    // MARK: - AudioPlayerDelegate

    func didPrepare(duration: TimeInterval) {
        self.isPlaying.accept(true)
        self.isPrepared.accept(true)

        self.remoteCommands.setup(show: self.show, episode: self.episode, duration: duration, currentTime: self.initialPlaybackSec ?? 0, currentRate: 1)
    }

    func didChangePlayingState(to state: ExCastPlayerState) {
        switch state {
        case .playing:
            isPlaying.accept(true)

        case .pause, .finish:
            isPlaying.accept(false)
        }
    }

    func didChangePlaybackTime(to time: TimeInterval) {
        self.currentTime.accept(time)
    }

    func didChangePlaybackRate(to rate: Double) {
        self.currentRate.accept(rate)
        self.remoteCommands.sync(currentTime: self.currentTime.value, currentRate: rate)
    }

    func didSeek(to _: TimeInterval) {
        self.remoteCommands.sync(currentTime: self.currentTime.value, currentRate: self.currentRate.value)
    }
}
