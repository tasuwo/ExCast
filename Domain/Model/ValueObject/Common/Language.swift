//
//  Language.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

/// IOS 639
/// http://www.loc.gov/standards/iso639-2/php/code_list.php
public enum Language: String, Codable {
    case english
    case japanese
    case chinese

    public var value: String {
        switch self {
        case .english:
            return "en"
        case .chinese:
            return "zho"
        case .japanese:
            return "ja"
        }
    }

    public init?(_ string: String) {
        switch string {
        case "en", "eng":
            self = .english
        case "ja", "jpn":
            self = .japanese
        case "zho", "chi", "zh":
            self = .chinese

        default:
            return nil
        }
    }
}
