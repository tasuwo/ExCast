//
//  NotificationAction.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/12.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UserNotifications

public protocol NotificationAction: CaseIterable {
    var title: String { get }
    var identifier: String { get }
}

extension NotificationAction {
    static func makeActions() -> [UNNotificationAction] {
        Self.allCases.map { aCase in aCase.makeUNNotificationAction() }
    }

    func makeUNNotificationAction() -> UNNotificationAction {
        UNNotificationAction(identifier: identifier,
                             title: title,
                             options: UNNotificationActionOptions(rawValue: 0))
    }
}

public enum GeneralNotificationAction: String, NotificationAction {
    case accept
    case decline

    // MARK: - NotificationAction

    public var title: String {
        switch self {
        case .accept:
            return NSLocalizedString("Notification.General.Accept", comment: "")

        case .decline:
            return NSLocalizedString("Notification.General.Decline", comment: "")
        }
    }

    public var identifier: String {
        rawValue
    }
}
