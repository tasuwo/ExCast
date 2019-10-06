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

    private let forwardSkipDuration: Double = 15
    private let backwardSkipDuration: Double = 15
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
         remoteCommands: ExCastPlayerDelegate) {
        self.show = show
        self.episode = episode
        self.commands = controller
        self.remoteCommands = remoteCommands

        self.currentTime
            .filter({ [unowned self] _ in self.preventToSyncTime.value == false })
            .bind(to: self.displayCurrentTime)
            .disposed(by: self.disposeBag)
        self.isSliderGrabbed
            .filter({ [unowned self] _ in self.isPrepared.value })
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
            .disposed(by: self.disposeBag)
    }

    // MARK: - Methods

    func setup() {
        self.commands.register(delegate: self)
        self.commands.register(delegate: self.remoteCommands)
        self.commands.prepareToPlay()
    }

    func playback() {
        if self.isPlaying.value {
            self.commands.pause()
        } else {
            self.commands.play()
        }
    }

    func skipForward() {
        self.commands.skipForward(duration: self.forwardSkipDuration) { _ in }
    }

    func skipBackward() {
        self.commands.skipBackward(duration: self.backwardSkipDuration) { _ in }
    }

}

extension PlayerControllerViewModel: ExCastPlayerDelegate {

    // MARK: - AudioPlayerDelegate

    func didFinishPrepare() {
        self.isPrepared.accept(true)

        if playedAfterLoadingOnce == false {
            self.commands.play()
            playedAfterLoadingOnce = true
        }
    }

    func didChangePlayingState(to state: ExCastPlayerState) {
        switch state {
        case .playing:
            self.isPlaying.accept(true)
        case .pause, .finish:
            self.isPlaying.accept(false)
        }
    }

    func didChangePlaybackTime(to time: TimeInterval) {
        self.currentTime.accept(time)
    }

    func didChangePlaybackRate(to rate: Double) {
        // NOP:
    }

    func didSeek(to time: TimeInterval) {
        // NOP:
    }

}
