//
//  PushNotificationSetting.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

public struct NotificationSetting: Codable {
    public let key: String
    public let deviceToken: Data
    public let context: NotificationContext
}
