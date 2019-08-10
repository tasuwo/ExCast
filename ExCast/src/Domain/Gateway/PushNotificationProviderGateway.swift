//
//  PushNotificationProviderGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

protocol PushNotificationProviderGateway {
    func register(_ token: Data)
    func unregister(_ token: Date)
}
