//
//  CommandCenter.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MediaPlayer
import UIKit

class RemoteCommandHandler: NSObject {
    private let show: Podcast.Show
    private let episode: Podcast.Episode
    private let commandCenter: MPRemoteCommandCenter
    private weak var player: ExCastPlayerProtocol?
    private unowned var infoCenter: MPNowPlayingInfoCenter

    private let configuration: PlayerConfiguration
    private var currentTime: TimeInterval = 0

    // MARK: - Lifecycle

    init(show: Podcast.Show, episode: Podcast.Episode, commandCenter: MPRemoteCommandCenter, player: ExCastPlayerProtocol, infoCenter: MPNowPlayingInfoCenter, configuration: PlayerConfiguration) {
        self.show = show
        self.episode = episode
        self.commandCenter = commandCenter
        self.player = player
        self.infoCenter = infoCenter
        self.configuration = configuration
    }

    deinit {
        self.infoCenter.nowPlayingInfo = nil
        self.commandCenter.playCommand.removeTarget(self)
        self.commandCenter.pauseCommand.removeTarget(self)
        self.commandCenter.skipForwardCommand.removeTarget(self)
        self.commandCenter.skipBackwardCommand.removeTarget(self)
        self.commandCenter.changePlaybackPositionCommand.removeTarget(self)
    }

    // MARK: - Methods

    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()

        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = show.title
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.meta.title

        if let pubDate = self.episode.meta.pubDate {
            nowPlayingInfo[MPMediaItemPropertyDateAdded] = pubDate
        }

        if let author = self.show.author {
            nowPlayingInfo[MPMediaItemPropertyArtist] = author
        }

        let description = episode.meta.description ?? show.description
        nowPlayingInfo[MPMediaItemPropertyComments] = description

        DispatchQueue.global(qos: .background).async {
            let artworkUrl = self.episode.meta.artwork ?? self.show.artwork
            guard let data = try? Data(contentsOf: artworkUrl), let image = UIImage(data: data) else { return }
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                image
            }
            self.infoCenter.nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
        }

        // TODO: 存在しなかった場合どうするか
        if let duration = self.episode.meta.duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }

        // TODO: 途中から再生の場合どうするか
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1

        infoCenter.nowPlayingInfo = nowPlayingInfo
    }

    private func setupRemoteTransportControls() {
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(didPlay(_:)))
        commandCenter.pauseCommand.addTarget(self, action: #selector(didPause(_:)))

        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: self.configuration.forwardSkipTime)]
        commandCenter.skipForwardCommand.addTarget(self, action: #selector(didSkipForward(_:)))

        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: self.configuration.backwardSkipTime)]
        commandCenter.skipBackwardCommand.addTarget(self, action: #selector(didSkipBackward(_:)))

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(didChangePlaybackPosition(_:)))
    }

    @objc private func didPlay(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.play()
        return .success
    }

    @objc private func didPause(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.pause()
        return .success
    }

    @objc private func didSkipForward(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.skipForward(duration: configuration.forwardSkipTime) { _ in }
        return .success
    }

    @objc private func didSkipBackward(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        player.skipBackward(duration: configuration.backwardSkipTime) { _ in }
        return .success
    }

    @objc private func didChangePlaybackPosition(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player,
            let event = event as? MPChangePlaybackPositionCommandEvent else {
            return .commandFailed
        }
        player.seek(to: event.positionTime) { _ in }
        return .success
    }
}

extension RemoteCommandHandler: ExCastPlayerDelegate {
    func didFinishPrepare() {
        setupNowPlayingInfo()
        setupRemoteTransportControls()
    }

    func didChangePlayingState(to _: ExCastPlayerState) {
        infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    }

    func didSeek(to _: TimeInterval) {
        infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    }

    func didChangePlaybackRate(to rate: Double) {
        infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = rate
    }

    func didChangePlaybackTime(to time: TimeInterval) {
        currentTime = time
    }
}
