//
//  NotificationService.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/14.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationService {

    private let notificationCenter: UNUserNotificationCenter
    private let gateway: PushNotificationProviderGateway
    private let repository: NotificationSettingRepository

    init(notificationCenter: UNUserNotificationCenter, gateway: PushNotificationProviderGateway, repository: NotificationSettingRepository) {
        self.notificationCenter = notificationCenter
        self.gateway = gateway
        self.repository = repository
    }

    func registerToApnsIfNeeded() {
        self.notificationCenter.setNotificationCategories(NotificationCategory.makeCategories())

        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        self.notificationCenter.getNotificationSettings { (setting) in
            switch setting.authorizationStatus {
            case .denied: break
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, err in
                    if let err = err {
                        // TODO:
                        print(err)
                        return
                    }

                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            @unknown default: break
            }
        }
    }

    func pushDeviceTokenToProvider(_ deviceToken: Data) {
        let context = self.repository.get()?.context ?? NotificationContext.default()
        self.gateway.register(deviceToken, context: context) { result in
            switch result {
            case let .success(key):
                let setting = NotificationSetting(key: key, deviceToken: deviceToken, context: context)
                try? self.repository.add(setting)
            case let .failure(err):
                // TODO:
                Swift.print(err)
            }
        }
    }

}
