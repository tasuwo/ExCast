//
//  CommandCenter.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MediaPlayer

class RemoteCommandHandler: NSObject {
    private let show: Podcast.Show
    private let episode: Podcast.Episode
    private let commandCenter: MPRemoteCommandCenter
    private weak var player: AudioPlayerControlCommands?
    private unowned var infoCenter: MPNowPlayingInfoCenter

    private let forwardSkipTimeInterval: TimeInterval = 15
    private let backwardSkipTimeInterval: TimeInterval = 15

    private var currentTime: TimeInterval = 0

    init(show: Podcast.Show, episode: Podcast.Episode, commandCenter: MPRemoteCommandCenter, player: AudioPlayerControlCommands, infoCenter: MPNowPlayingInfoCenter) {
        self.show = show
        self.episode = episode
        self.commandCenter = commandCenter
        self.player = player
        self.infoCenter = infoCenter
    }

    deinit {
        self.infoCenter.nowPlayingInfo = nil
        self.commandCenter.playCommand.removeTarget(self)
        self.commandCenter.pauseCommand.removeTarget(self)
        self.commandCenter.skipForwardCommand.removeTarget(self)
        self.commandCenter.skipBackwardCommand.removeTarget(self)
        self.commandCenter.changePlaybackPositionCommand.removeTarget(self)
    }

    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String : Any]()

        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = self.show.title
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.episode.title

        if let pubDate = self.episode.pubDate {
            nowPlayingInfo[MPMediaItemPropertyDateAdded] = pubDate
        }

        if let author = self.show.author {
            nowPlayingInfo[MPMediaItemPropertyArtist] = author
        }

        let description = self.episode.description ?? self.show.description
        nowPlayingInfo[MPMediaItemPropertyComments] = description

        DispatchQueue.global(qos: .background).async {
            let artworkUrl = self.episode.artwork ?? self.show.artwork
            guard let data = try? Data(contentsOf: artworkUrl), let image = UIImage(data: data) else { return }
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            self.infoCenter.nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
        }

        // TODO: 存在しなかった場合どうするか
        if let duration = self.episode.duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1

        self.infoCenter.nowPlayingInfo = nowPlayingInfo
    }

    // TODO: 失敗を通知する
    private func setupRemoteTransportControls() {
        self.commandCenter.nextTrackCommand.isEnabled = false
        self.commandCenter.previousTrackCommand.isEnabled = false

        self.commandCenter.togglePlayPauseCommand.isEnabled = true
        self.commandCenter.playCommand.addTarget(self, action: #selector(self.didPlay(_:)))
        self.commandCenter.pauseCommand.addTarget(self, action: #selector(self.didPause(_:)))

        self.commandCenter.skipForwardCommand.isEnabled = true
        self.commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: self.forwardSkipTimeInterval)]
        self.commandCenter.skipForwardCommand.addTarget(self, action: #selector(self.didSkipForward(_:)))

        self.commandCenter.skipBackwardCommand.isEnabled = true
        self.commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: self.backwardSkipTimeInterval)]
        self.commandCenter.skipBackwardCommand.addTarget(self, action: #selector(self.didSkipBackward(_:)))

        self.commandCenter.changePlaybackPositionCommand.isEnabled = true
        self.commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(self.didChangePlaybackPosition(_:)))
    }

    @objc private func didPlay(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.play()
        return .success
    }

    @objc private func didPause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.pause()
        return .success
    }

    @objc private func didSkipForward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.skip(direction: .forward, duration: self.forwardSkipTimeInterval) { success in
            if success {
                self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
            }
        }
        return .success
    }

    @objc private func didSkipBackward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.skip(direction: .backward, duration: self.backwardSkipTimeInterval) { success in
            if success {
                self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
            }
        }
        return .success
    }

    @objc private func didChangePlaybackPosition(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player,
              let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
        }
        player.seek(to: event.positionTime) { success in
            if success {
                self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
            }
        }
        return .success
    }
}

extension RemoteCommandHandler: AudioPlayerDelegate {

    func didFinishPrepare() {
        self.setupNowPlayingInfo()
        self.setupRemoteTransportControls()
    }

    func didChangePlayingState(to state: AudioPlayer.PlayingState) {
        // NOP:
    }

    func didChangePlaybackTime(to time: TimeInterval) {
        self.currentTime = time
    }

}
