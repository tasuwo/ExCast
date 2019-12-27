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
        return rawValue
    }

    var actions: [UNNotificationAction] {
        switch self {
        case .GENERAL:
            return GeneralNotificationAction.makeActions()
        }
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

    public static func makeCategories() -> Set<UNNotificationCategory> {
        return Set(Self.allCases.map { `case` in `case`.makeUNNotificationCategory() })
    }
}