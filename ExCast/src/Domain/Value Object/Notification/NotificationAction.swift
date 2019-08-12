//
//  NotificationAction.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/12.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UserNotifications

protocol NotificationAction: CaseIterable {
    var title: String { get }
    var identifier: String { get }
}

extension NotificationAction {
    func makeUNNotificationAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: self.identifier,
                                    title: self.title,
                                    options: UNNotificationActionOptions(rawValue: 0))
    }

    static func makeActions() -> Array<UNNotificationAction> {
        return Self.allCases.map { `case` in `case`.makeUNNotificationAction() }
    }
}

enum GeneralNotificationAction: String, NotificationAction {
    case Accept
    case Decline

    // MARK: - NotificationAction

    var title: String {
        switch self {
        case .Accept:
            return NSLocalizedString("Notification.General.Accept", comment: "")
        case .Decline:
            return NSLocalizedString("Notification.General.Decline", comment: "")
        }
    }

    var identifier: String {
        return self.rawValue
    }
}
