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
    case English
    case Japanese
    case Chinese

    public var value: String {
        switch self {
        case .English:
            return "en"
        case .Chinese:
            return "zho"
        case .Japanese:
            return "ja"
        }
    }

    public init?(_ string: String) {
        switch string {
        case "en", "eng":
            self = .English
        case "ja", "jpn":
            self = .Japanese
        case "zho", "chi", "zh":
            self = .Chinese
        default:
            return nil
        }
    }
}
