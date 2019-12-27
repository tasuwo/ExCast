//
//  Enclosure.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

// sourcery: model
/// The episode content, file size, and file type information.
/// https://help.apple.com/itc/podcasts_connect/#/itcb54353390
public struct Enclosure: Codable, Equatable {
    public enum FileFormat: String, Codable, Equatable {
        case M4A
        case MP3
        case MOV
        case MP4
        case M4V
        case PDF

        public static func from(_ string: String) -> FileFormat? {
            switch string {
            case "audio/x-m4a":
                return .M4A
            case "audio/mpeg":
                fallthrough
            case "audio/mp3":
                return .MP3
            case "video/quicktime":
                return .MOV
            case "video/mp4":
                return .MP4
            case "video/x-m4v":
                return .M4V
            case "application/pdf":
                return .PDF
            default:
                return nil
            }
        }
    }

    public enum ResourceType: String, Codable, Equatable {
        case AUDIO
        case VIDEO
        case APPLICATION

        static func from(format: FileFormat) -> ResourceType {
            switch format {
            case .M4A:
                return .AUDIO
            case .MP3:
                return .AUDIO
            case .MOV:
                return .VIDEO
            case .MP4:
                return .VIDEO
            case .M4V:
                return .VIDEO
            case .PDF:
                return .APPLICATION
            }
        }
    }

    /// The URL which points to podcast media file.
    public let url: URL

    /// The file size in bytes.
    public let length: Int

    /// The correct category for the type of file.
    public let type: FileFormat

    // MARK: - Lifecycle

    public init(
        url: URL,
        length: Int,
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
        guard
            let attributes = (node |> "enclosure")?.attributes,
            let url = URL(string: attributes["url"] ?? ""),
            let type = Enclosure.FileFormat.from(attributes["type"] ?? ""),
            let length = Int(attributes["length"] ?? "") else {
            return nil
        }
        self.url = url
        self.length = length
        self.type = type
    }
}
