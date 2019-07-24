//
//  EpisodePlayerViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

struct EpisodePlayerViewModel {
    let episode: Podcast.Episode
    private var commands: AudioPlayerControlCommands

    private let forwardSkipDuration: Double = 10
    private let backwardSkipDuration: Double = 10

    var isPlaying: Dynamic<Bool>
    var isPrepared: Dynamic<Bool>
    var currentTime: Dynamic<Double>
    var displayCurrentTime: Dynamic<Double> = Dynamic(0)
    var isSliderGrabbed: Dynamic<Bool>

    private var currentTimeBond: Bond<Double>!
    private var isSliderGrabbedBond: Bond<Bool>!

    init(controller: AudioPlayerControlCommands, episode: Podcast.Episode) {
        self.commands = controller
        self.episode = episode

        self.isPlaying = Dynamic(false)
        self.isPrepared = Dynamic(false)
        self.currentTime = Dynamic(0)
        self.isSliderGrabbed = Dynamic(false)
    }

    // MARK: - Methods

    mutating func setup() {
        // TODO: 初回の同期を綺麗にする
        self.isPlaying.value = false
        self.isPrepared.value = false
        self.currentTime.value = 0

        self.commands.delegate = self
        self.commands.prepareToPlay()

        // Bind
        self.currentTimeBond = Bond() { [self] currentTime in
            self.displayCurrentTime.value = currentTime
        }
        self.currentTimeBond.bind(self.currentTime)

        self.isSliderGrabbedBond = Bond() { [self] isGrabbed in
            if isGrabbed {
                self.currentTimeBond.release(self.currentTime)
            } else {
                // TODO: シーク完了を待ってからバインドすべき
                self.commands.seek(to: self.displayCurrentTime.value)
                self.currentTimeBond.bind(self.currentTime)
            }
        }
        self.isSliderGrabbedBond.bind(self.isSliderGrabbed)
    }

    func playback() {
        if self.isPlaying.value {
            self.commands.pause()
        } else {
            self.commands.play()
        }
    }

    func skipForward() {
        self.commands.skip(direction: .forward, duration: self.forwardSkipDuration)
    }

    func skipBackward() {
        self.commands.skip(direction: .backward, duration: self.backwardSkipDuration)
    }

}

extension EpisodePlayerViewModel: AudioPlayerDelegate {

    // MARK: - AudioPlayerDelegate

    func didFinishPrepare() {
        self.isPrepared.value = true
    }

    func didChangePlayingState(to state: AudioPlayer.PlayingState) {
        switch state {
        case .playing:
            self.isPlaying.value = true
        case .pause, .finish:
            self.isPlaying.value = false
        }
    }

    func didChangePlaybackTime(to time: TimeInterval) {
        self.currentTime.value = time
    }

}
