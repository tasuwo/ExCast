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
    let show: Podcast.Show
    let episode: Podcast.Episode
    private let commands: ExCastPlayerProtocol
    private let remoteCommands: ExCastPlayerDelegate
    private let configuration: PlayerConfiguration

    private var playedAfterLoadingOnce: Bool = false

    var isPlaying: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isPrepared: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var currentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    var displayCurrentTime: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    var isSliderGrabbed: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private var preventToSyncTime: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(show: Podcast.Show,
         episode: Podcast.Episode,
         controller: ExCastPlayerProtocol,
         remoteCommands: ExCastPlayerDelegate,
         configuration: PlayerConfiguration) {
        self.show = show
        self.episode = episode
        commands = controller
        self.remoteCommands = remoteCommands
        self.configuration = configuration

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
    }

    // MARK: - Methods

    func setup() {
        commands.register(delegate: self)
        commands.register(delegate: remoteCommands)
        commands.prepareToPlay()
    }

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
