//
//  CommandCenter.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MediaPlayer
import UIKit

public protocol RemoteCommandHandlerProtocol {
    func register(delegate player: ExCastPlayerProtocol)
    func setup(show: Show, episode: Episode, duration: Double, currentTime: Double, currentRate: Double)
    func sync(currentTime: Double, currentRate: Double)
}

public class RemoteCommandHandler: NSObject {
    public weak var player: ExCastPlayerProtocol?
    private let commandCenter: MPRemoteCommandCenter
    private unowned var infoCenter: MPNowPlayingInfoCenter

    private let configuration: PlayerConfiguration
    private var currentTime: TimeInterval = 0

    // MARK: - Lifecycle

    public init(commandCenter: MPRemoteCommandCenter, infoCenter: MPNowPlayingInfoCenter, configuration: PlayerConfiguration) {
        self.commandCenter = commandCenter
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

    private func setupNowPlayingInfo(show: Show, episode: Episode, duration: Double, currentTime: Double, currentRate: Double) {
        var nowPlayingInfo = [String: Any]()

        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = show.title
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.meta.title

        if let pubDate = episode.meta.pubDate {
            nowPlayingInfo[MPMediaItemPropertyDateAdded] = pubDate
        }

        if let author = show.author {
            nowPlayingInfo[MPMediaItemPropertyArtist] = author
        }

        let description = episode.meta.itemDescription ?? show.showDescription
        nowPlayingInfo[MPMediaItemPropertyComments] = description

        DispatchQueue.global(qos: .background).async {
            let artworkUrl = episode.meta.artwork ?? show.artwork
            guard let data = try? Data(contentsOf: artworkUrl), let image = UIImage(data: data) else { return }
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                image
            }
            self.infoCenter.nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = currentRate

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

extension RemoteCommandHandler: RemoteCommandHandlerProtocol {
    // MARK: - RemoteCommandHandlerProtocol

    public func register(delegate player: ExCastPlayerProtocol) {
        self.player = player
    }

    public func setup(show: Show, episode: Episode, duration: Double, currentTime: Double, currentRate: Double) {
        self.setupNowPlayingInfo(show: show, episode: episode, duration: duration, currentTime: currentTime, currentRate: currentRate)
        self.setupRemoteTransportControls()
    }

    public func sync(currentTime: Double, currentRate: Double) {
        self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = currentRate
    }
}
