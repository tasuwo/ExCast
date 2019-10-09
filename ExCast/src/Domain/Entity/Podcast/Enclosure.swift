//
//  Enclosure.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

/// The episode content, file size, and file type information.
/// https://help.apple.com/itc/podcasts_connect/#/itcb54353390
struct Enclosure: Codable, Equatable {
    enum FileFormat: String, Codable, Equatable {
        case M4A
        case MP3
        case MOV
        case MP4
        case M4V
        case PDF

        static func from(_ string: String) -> FileFormat? {
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

    enum ResourceType: String, Codable, Equatable {
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
    let url: URL

    /// The file size in bytes.
    let length: Int

    /// The correct category for the type of file.
    let type: FileFormat
}
