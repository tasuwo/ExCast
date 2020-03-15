//
//  Enclosure.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Common
import Foundation

// sourcery: model
/// The episode content, file size, and file type information.
/// https://help.apple.com/itc/podcasts_connect/#/itcb54353390
public struct Enclosure: Codable, Equatable {
    public enum FileFormat: String, Codable, Equatable {
        case m4a
        case mp3
        case mov
        case mp4
        case m4v
        case pdf

        public static func from(_ string: String) -> FileFormat? {
            switch string {
            case "audio/x-m4a":
                return .m4a
            case "audio/mpeg",
                 "audio/mp3":
                return .mp3
            case "video/quicktime":
                return .mov
            case "video/mp4":
                return .mp4
            case "video/x-m4v":
                return .m4v
            case "application/pdf":
                return .pdf

            default:
                return nil
            }
        }
    }

    public enum ResourceType: String, Codable, Equatable {
        case audio
        case video
        case application

        static func from(format: FileFormat) -> ResourceType {
            switch format {
            case .m4a:
                return .audio

            case .mp3:
                return .audio

            case .mov:
                return .video

            case .mp4:
                return .video

            case .m4v:
                return .video

            case .pdf:
                return .application
            }
        }
    }

    /// The URL which points to podcast media file.
    public let url: URL

    /// The file size in bytes.
    public let length: Int?

    /// The correct category for the type of file.
    public let type: FileFormat

    // MARK: - Lifecycle

    public init(
        url: URL,
        length: Int?,
        type: FileFormat
    ) {
        self.url = url
        self.length = length
        self.type = type
    }
}

extension Enclosure {
    // MARK: - Lifecycle

    public init?(node: XmlNode) {
        guard let attributes = (node |> "enclosure")?.attributes else {
            errorLog("Failed to initialize Enclosure. No `enclosure` element.")
            return nil
        }

        guard let urlString = attributes["url"] else {
            errorLog("Failed to initialize Enclosure. No `url` attribute in `enclosure` element.")
            return nil
        }
        guard let url = URL(string: urlString) else {
            errorLog("Failed to initialize Enclosure. Invalid `url` (\(urlString)) in `enclosure` element.")
            return nil
        }

        guard let typeString = attributes["type"] else {
            errorLog("Failed to initialize Enclosure. No `type` attribute in `enclosure` element.")
            return nil
        }
        guard let type = Enclosure.FileFormat.from(typeString) else {
            errorLog("Failed to initialize Enclosure. Invalid `type` attribute (\(typeString)) in `enclosure` element.")
            return nil
        }

        guard let lengthString = attributes["length"] else {
            errorLog("Failed to initialize Enclosure. No `length` attribute in `enclosure` element.")
            return nil
        }

        self.url = url
        length = Int(lengthString)
        self.type = type
    }
}
