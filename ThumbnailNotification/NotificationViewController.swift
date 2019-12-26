//
//  NotificationViewController.swift
//  ThumbnailNotification
//
//  Created by Tasuku Tozawa on 2019/08/13.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet var label: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }

    func didReceive(_ notification: UNNotification) {
        label?.text = notification.request.content.body
    }
}
