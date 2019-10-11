//
//  AppDelegate.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import AVFoundation
import AWSSNS
import Keys
import MediaPlayer
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let keys = ExCastKeys()
    var notificationService: NotificationService?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // AVPlayer
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

        // AWS
        AWSServiceManager.default()?.defaultServiceConfiguration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: self)

        // Notification
        // let notificationCenter = UNUserNotificationCenter.current()
        // notificationCenter.delegate = self
        // let gateway = PushNotificationProviderGatewayImpl(snsClient: AWSSNS.default(), applicationArn: keys.awsSnsApplicationArn)
        // let repository = NotificationSettingRepositoryImpl(repository: LocalRepositoryImpl(defaults: UserDefaults.standard))
        // self.notificationService = NotificationService(notificationCenter: notificationCenter, gateway: gateway, repository: repository)

        notificationService?.registerToApnsIfNeeded()

        // Window
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            let container = DependencyContainer()
            let rootViewController = AppRootViewController(factory: container)
            container.episodePlayerModalPresenter = rootViewController

            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // NOP
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // NOP
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // NOP
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // NOP
    }

    func applicationWillTerminate(_: UIApplication) {
        // NOP
    }

    // MARK: - Notification

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        notificationService?.pushDeviceTokenToProvider(deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // TODO:
        Swift.print(error)
    }
}

extension AppDelegate: AWSCredentialsProvider {
    // MARK: - AWSCredentialsProvider

    func credentials() -> AWSTask<AWSCredentials> {
        return AWSTask(result: AWSCredentials(accessKey: keys.awsAccessKey, secretKey: keys.awsSecretKey, sessionKey: nil, expiration: nil))
    }

    func invalidateCachedTemporaryCredentials() {
        // NOP
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Push Notification will present")
        completionHandler([.badge, .sound, .alert])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO:
        let category = NotificationCategory(rawValue: response.notification.request.content.categoryIdentifier)
        switch (category, response.actionIdentifier) {
        case (.GENERAL, GeneralNotificationAction.Accept.rawValue):
            print("Touch accept.")
        case (.GENERAL, GeneralNotificationAction.Decline.rawValue):
            print("Touch decline.")
        case (_, UNNotificationDefaultActionIdentifier),
             (_, UNNotificationDismissActionIdentifier):
            break
        default:
            break
        }

        completionHandler()
    }
}
