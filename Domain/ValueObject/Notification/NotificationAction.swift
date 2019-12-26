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
    func makeUNNotificationAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: identifier,
                                    title: title,
                                    options: UNNotificationActionOptions(rawValue: 0))
    }

    static func makeActions() -> [UNNotificationAction] {
        return Self.allCases.map { `case` in `case`.makeUNNotificationAction() }
    }
}

public enum GeneralNotificationAction: String, NotificationAction {
    case Accept
    case Decline

    // MARK: - NotificationAction

    public var title: String {
        switch self {
        case .Accept:
            return NSLocalizedString("Notification.General.Accept", comment: "")
        case .Decline:
            return NSLocalizedString("Notification.General.Decline", comment: "")
        }
    }

    public var identifier: String {
        return rawValue
    }
}
