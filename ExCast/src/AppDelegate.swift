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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var provider: PushNotificationProviderGateway?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, err in }

        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            if setting.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        AWSServiceManager.default()?.defaultServiceConfiguration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: self)
        // TODO:
        self.provider = PushNotificationProviderGatewayImpl(snsClient: AWSSNS.default(), applicationArn: "")

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
        self.provider?.register(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Swift.print(error)
    }

}

extension AppDelegate: AWSCredentialsProvider {
    func credentials() -> AWSTask<AWSCredentials> {
        // TODO:
        return AWSTask(result: AWSCredentials(accessKey: "", secretKey: "", sessionKey: nil, expiration: nil))
    }

    func invalidateCachedTemporaryCredentials() {
        // NOP
    }

}

