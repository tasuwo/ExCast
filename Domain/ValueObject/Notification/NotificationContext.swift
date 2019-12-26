//
//  NotificationContext.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

public struct NotificationContext: Codable {
    public let lang: String

    public static func `default`() -> NotificationContext {
        return NotificationContext(lang: "ja")
    }
}
