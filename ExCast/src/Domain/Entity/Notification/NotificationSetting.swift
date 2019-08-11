//
//  PushNotificationSetting.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

struct NotificationSetting: Codable {
    let key: String
    let deviceToken: Data
    let context: NotificationContext
}
