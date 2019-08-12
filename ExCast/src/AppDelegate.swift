//
//  AppDelegate.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AWSSNS
import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let keys = ExCastKeys()
    var provider: PushNotificationProviderGateway?
    var settingRepository: NotificationSettingRepository?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // AVPlayer
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

        // Notification
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setNotificationCategories(NotificationCategory.makeCategories())
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, err in
            if !granted {
                print("User has declined notifidations.")
            }
        }
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            guard setting.authorizationStatus == .authorized else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        AWSServiceManager.default()?.defaultServiceConfiguration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: self)
        self.provider = PushNotificationProviderGatewayImpl(snsClient: AWSSNS.default(), applicationArn: keys.awsSnsApplicationArn)

        // Setting
        self.settingRepository = NotificationSettingRepositoryImpl(repository: LocalRepositoryImpl(defaults: UserDefaults.standard))

        // Window
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = AppRootViewController()
            window.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // NOP
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // NOP
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // NOP
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // NOP
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // NOP
    }

    // MARK: - Notification

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let context = self.settingRepository?.get()?.context ?? NotificationContext.default()
        self.provider?.register(deviceToken, context: context) { result in
            switch result {
            case let .success(key):
                let setting = NotificationSetting(key: key, deviceToken: deviceToken, context: context)
                try? self.settingRepository?.add(setting)
            case let .failure(err):
                Swift.print(err)
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
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

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Push Notification will present")
        completionHandler([.badge, .sound, .alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

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
