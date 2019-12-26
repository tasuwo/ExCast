//
//  Date+fromRfc822.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/04.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

/**
 * Returns a date representation of given string conform to [RFC822](https://tools.ietf.org/html/rfc822#section-5).
 */
public func parseRfc822DateString(_ dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")

    if dateString.contains(",") {
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: dateString)
    } else {
        formatter.dateFormat = "d MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: dateString)
    }
}
