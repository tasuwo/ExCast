//
//  NotificationContext.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

struct NotificationContext: Codable {
    let lang: String

    static func `default`() -> NotificationContext {
        return NotificationContext(lang: "ja")
    }
}
