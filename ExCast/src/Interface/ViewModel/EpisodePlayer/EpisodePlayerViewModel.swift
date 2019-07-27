//
//  EpisodePlayerViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import MediaPlayer

class EpisodePlayerViewModel {
    let show: Podcast.Show
    let episode: Podcast.Episode
    private let commands: AudioPlayerControlCommands
    private let commandCenter: RemoteCommandHandler

    private let forwardSkipDuration: Double = 10
    private let backwardSkipDuration: Double = 10

    var isPlaying: Dynamic<Bool>
    var isPrepared: Dynamic<Bool>
    var currentTime: Dynamic<Double>
    var displayCurrentTime: Dynamic<Double> = Dynamic(0)
    var isSliderGrabbed: Dynamic<Bool>

    private var currentTimeBond: Bond<Double>!
    private var isSliderGrabbedBond: Bond<Bool>!

    init(show: Podcast.Show, episode: Podcast.Episode, controller: AudioPlayerControlCommands) {
        self.show = show
        self.episode = episode
        self.commands = controller
        // TODO: DI
        self.commandCenter = RemoteCommandHandler(
            show: self.show,
            episode: self.episode,
            commandCenter: MPRemoteCommandCenter.shared(),
            player: self.commands,
            infoCenter: MPNowPlayingInfoCenter.default()
        )

        self.isPlaying = Dynamic(false)
        self.isPrepared = Dynamic(false)
        self.currentTime = Dynamic(0)
        self.isSliderGrabbed = Dynamic(false)
    }

    // MARK: - Methods

    func setup() {
        // TODO: 初回の同期を綺麗にする
        self.isPlaying.value = false
        self.isPrepared.value = false
        self.currentTime.value = 0

        self.commands.add(delegate: self)
        self.commands.add(delegate: self.commandCenter)
        self.commands.prepareToPlay()

        // Bind
        self.currentTimeBond = Bond() { [unowned self] currentTime in
            self.displayCurrentTime.value = currentTime
        }
        self.currentTimeBond.bind(self.currentTime)

        self.isSliderGrabbedBond = Bond() { [unowned self] isGrabbed in
            if isGrabbed {
                self.currentTimeBond.release(self.currentTime)
            } else {
                self.commands.seek(to: self.displayCurrentTime.value) { [unowned self] result in
                    if result == false {
                        // TODO: Error handling
                    }

                    self.currentTimeBond.bind(self.currentTime)
                }
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
        self.commands.skip(direction: .forward, duration: self.forwardSkipDuration) { _ in }
    }

    func skipBackward() {
        self.commands.skip(direction: .backward, duration: self.backwardSkipDuration) { _ in }
    }

}

extension EpisodePlayerViewModel: AudioPlayerDelegate {

    // MARK: - AudioPlayerDelegate

    func didFinishPrepare() {
        self.isPrepared.value = true
        self.commands.play()
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
