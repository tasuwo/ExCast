//
//  EpisodePlayerViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

struct EpisodePlayerViewModel {
    private let episode: Podcast.Episode
    private var commands: AudioPlayerControlCommands

    private let forwardSkipDuration: Double = 10
    private let backwardSkipDuration: Double = 10

    var isPlaying: Dynamic<Bool>
    var isPrepared: Dynamic<Bool>
    var currentTime: Dynamic<Double>
    // 表示中の時刻とプレーヤーの時刻は別に作った方が良さそう

    init(controller: AudioPlayerControlCommands, episode: Podcast.Episode) {
        self.commands = controller
        self.episode = episode

        self.isPlaying = Dynamic(false)
        self.isPrepared = Dynamic(false)
        self.currentTime = Dynamic(0)
    }

    // MARK: - Methods

    mutating func setup() {
        // TODO: 初回の同期を綺麗にする
        self.isPlaying.value = false
        self.isPrepared.value = false
        self.currentTime.value = 0

        self.commands.delegate = self
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
