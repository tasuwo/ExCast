//
//  NotificaitonCategory.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/12.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UserNotifications

enum NotificationCategory: String, CaseIterable {
    case GENERAL

    var identifier: String {
        return self.rawValue
    }

    var actions: Array<UNNotificationAction> {
        switch self {
        case .GENERAL:
            return GeneralNotificationAction.makeActions()
        }
    }

    func makeUNNotificationCategory() -> UNNotificationCategory {
        switch self {
        case .GENERAL:
            return UNNotificationCategory(identifier: self.identifier,
                                          actions: self.actions,
                                          intentIdentifiers: [],
                                          options: .customDismissAction)
        }
    }

    static func makeCategories() -> Set<UNNotificationCategory> {
        return Set(Self.allCases.map { `case` in `case`.makeUNNotificationCategory() })
    }
}
