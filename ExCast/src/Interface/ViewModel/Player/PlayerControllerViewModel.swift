//
//  EpisodePlayerControllerViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation
import RxRelay
import RxSwift
import MediaPlayer

class PlayerControllerViewModel {
    private let show: Show
    private let episode: Episode
    private var player: ExCastPlayerProtocol!
    private let configuration: PlayerConfiguration
    private let remoteCommands: RemoteCommandHandler
    private let episodeService: EpisodeServiceProtocol

    private var playedAfterLoadingOnce: Bool = false

    private(set) var createdPlayer: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var isPlaying: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var isPrepared: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var duration: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var currentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var displayCurrentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var isSliderGrabbed: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private var preventToSyncTime: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(show: Show, episode: Episode, remoteCommands: RemoteCommandHandler, configuration: PlayerConfiguration, episodeService: EpisodeServiceProtocol) {
        self.show = show
        self.episode = episode
        self.remoteCommands = remoteCommands
        self.configuration = configuration
        self.duration.accept(episode.meta.duration ?? 0)
        self.episodeService = episodeService

        self.currentTime
            .filter { [unowned self] _ in self.preventToSyncTime.value == false }
            .bind(to: displayCurrentTime)
            .disposed(by: disposeBag)

        self.isSliderGrabbed
            .filter { [unowned self] _ in self.isPrepared.value }
            .bind(onNext: { [unowned self] grabbed in
                if grabbed {
                    self.preventToSyncTime.accept(true)
                } else {
                    self.player.seek(to: self.displayCurrentTime.value) { isSucceeded in
                        guard isSucceeded else { return }
                        self.displayCurrentTime.accept(self.currentTime.value)
                        self.preventToSyncTime.accept(false)
                    }
                }
            })
            .disposed(by: disposeBag)

        self.currentTime
            .bind(onNext: { [unowned self] time in
                self.episodeService.command.accept(.update(self.episode.identity, .init(playbackPositionSec: Int(time))))
            })
            .disposed(by: disposeBag)

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            self.player = ExCastPlayer(contentUrl: self.episode.meta.enclosure.url,
                                       startPlayAutomatically: true,
                                       // 再生位置が保存されていた場合は、resume再生する
                                       playbackSec: self.episode.playback?.playbackPositionSec ?? 0)
            self.player.register(delegate: self)

            self.remoteCommands.player = self.player
            self.player.register(delegate: self.remoteCommands)

            self.player.createdPlayer
                .bind(to: self.createdPlayer)
                .disposed(by: self.disposeBag)

        }
    }

    // MARK: - Methods

    func playback() {
        if isPlaying.value {
            player.pause()
        } else {
            player.play()
        }
    }

    func skipForward() {
        player.skipForward(duration: configuration.forwardSkipTime) { _ in }
    }

    func skipBackward() {
        player.skipBackward(duration: configuration.backwardSkipTime) { _ in }
    }
}

extension PlayerControllerViewModel: ExCastPlayerDelegate {
    // MARK: - AudioPlayerDelegate

    func didFinishPrepare() {
        self.isPlaying.accept(true)
        self.isPrepared.accept(true)
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
        currentTime.accept(time)
    }

    func didChangePlaybackRate(to _: Double) {
        // NOP:
    }

    func didSeek(to _: TimeInterval) {
        // NOP:
    }
}
