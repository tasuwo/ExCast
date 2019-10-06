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
enum Language: String, Codable {
    case English
    case Japanese
    case Chinese

    static func fromString(_ string: String) -> Language? {
        switch string {
        case "en", "eng":
            return .English
        case "ja", "jpn":
            return .Japanese
        case "zho", "chi", "zh":
            return .Chinese
        default:
            return nil
        }
    }
}
