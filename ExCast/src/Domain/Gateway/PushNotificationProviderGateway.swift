//
//  PushNotificationProviderGateway.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

enum PushNotificationProviderGatewayError: Error {
    case InvalidParameterError
    case InvalidResponse
    case InternalServerError(Error)
}

typealias ProviderKey = String

protocol PushNotificationProviderGateway {

    func register(_ token: Data, context: NotificationContext, completion: @escaping (Result<ProviderKey,PushNotificationProviderGatewayError>) -> Void)

    func update(_ key: ProviderKey, context: NotificationContext, completion: @escaping (Result<Void,PushNotificationProviderGatewayError>) -> Void)

    func unregister(_ key: ProviderKey, completion: @escaping (Result<Void,PushNotificationProviderGatewayError>) -> Void)
}
