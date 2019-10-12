//
//  EpisodePlayerControllerViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

class PlayerControllerViewModel {
    private let show: Podcast.Show
    private let episode: Podcast.Episode
    private let commands: ExCastPlayerProtocol
    private let configuration: PlayerConfiguration
    private let remoteCommands: ExCastPlayerDelegate

    private var playedAfterLoadingOnce: Bool = false

    private(set) var isPlaying: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var isPrepared: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private(set) var duration: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var currentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var displayCurrentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private(set) var isSliderGrabbed: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private var preventToSyncTime: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(show: Podcast.Show, episode: Podcast.Episode, controller: ExCastPlayerProtocol, remoteCommands: ExCastPlayerDelegate, configuration: PlayerConfiguration) {
        self.show = show
        self.episode = episode
        self.commands = controller
        self.configuration = configuration
        self.remoteCommands = remoteCommands
        duration.accept(episode.duration ?? 0)

        currentTime
            .filter { [unowned self] _ in self.preventToSyncTime.value == false }
            .bind(to: displayCurrentTime)
            .disposed(by: disposeBag)
        isSliderGrabbed
            .filter { [unowned self] _ in self.isPrepared.value }
            .bind(onNext: { [unowned self] grabbed in
                if grabbed {
                    self.preventToSyncTime.accept(true)
                } else {
                    self.commands.seek(to: self.displayCurrentTime.value) { isSucceeded in
                        guard isSucceeded else { return }
                        self.displayCurrentTime.accept(self.currentTime.value)
                        self.preventToSyncTime.accept(false)
                    }
                }
            })
            .disposed(by: disposeBag)

        commands.register(delegate: self)
        commands.register(delegate: remoteCommands)
        commands.prepareToPlay()
    }

    // MARK: - Methods

    func playback() {
        if isPlaying.value {
            commands.pause()
        } else {
            commands.play()
        }
    }

    func skipForward() {
        commands.skipForward(duration: configuration.forwardSkipTime) { _ in }
    }

    func skipBackward() {
        commands.skipBackward(duration: configuration.backwardSkipTime) { _ in }
    }
}

extension PlayerControllerViewModel: ExCastPlayerDelegate {
    // MARK: - AudioPlayerDelegate

    func didFinishPrepare() {
        isPrepared.accept(true)

        if playedAfterLoadingOnce == false {
            commands.play()
            playedAfterLoadingOnce = true
        }
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
