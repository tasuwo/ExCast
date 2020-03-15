//
//  NotificaitonCategory.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/12.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UserNotifications

public enum NotificationCategory: String, CaseIterable {
    case GENERAL

    var identifier: String {
        rawValue
    }

    var actions: [UNNotificationAction] {
        switch self {
        case .GENERAL:
            return GeneralNotificationAction.makeActions()
        }
    }

    public static func makeCategories() -> Set<UNNotificationCategory> {
        Set(Self.allCases.map { aCase in aCase.makeUNNotificationCategory() })
    }

    public func makeUNNotificationCategory() -> UNNotificationCategory {
        switch self {
        case .GENERAL:
            return UNNotificationCategory(identifier: identifier,
                                          actions: self.actions,
                                          intentIdentifiers: [],
                                          options: .customDismissAction)
        }
    }
}
