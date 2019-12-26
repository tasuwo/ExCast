//
//  PushNotificationProviderGatewayImpl.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import AWSSNS
import Domain

class PushNotificationProviderGateway: PushNotificationProviderGatewayProtocol {
    let snsClient: AWSSNS
    let applicationArn: String

    init(snsClient: AWSSNS, applicationArn: String) {
        self.snsClient = snsClient
        self.applicationArn = applicationArn
    }

    func register(_ token: Data, context: NotificationContext, completion: @escaping (Result<ProviderKey, PushNotificationProviderGatewayError>) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(context),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
            completion(Result.failure(.InvalidParameterError))
            return
        }
        let tokenString = token.map { String(format: "%.2hhx", $0) }.joined()

        // NOTE: see also https://docs.aws.amazon.com/sns/latest/api/API_CreatePlatformEndpoint.html
        let params: [String: Any] = [
            "token": tokenString,
            "customUserData": jsonString,
            "platformApplicationArn": applicationArn,
        ]
        let input = try! AWSSNSCreatePlatformEndpointInput(dictionary: params, error: ())

        snsClient.createPlatformEndpoint(input).continueWith(executor: .mainThread()) { task in
            if let err = task.error as NSError? {
                switch (err.domain, err.code) {
                case (AWSSNSErrorDomain, AWSSNSErrorType.invalidParameter.rawValue):
                    // TODO: contextの不整合が発生したら更新したい
                    completion(Result.failure(.InternalServerError(err)))
                default:
                    completion(Result.failure(.InternalServerError(err)))
                }
                return nil
            }

            guard let endpointArn = task.result?.endpointArn else {
                completion(Result.failure(.InvalidResponse))
                return nil
            }

            completion(Result.success(endpointArn))
            return nil
        }
    }

    func update(_ key: ProviderKey, context: NotificationContext, completion: @escaping (Result<Void, PushNotificationProviderGatewayError>) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(context),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
            completion(Result.failure(.InvalidParameterError))
            return
        }

        // NOTE: see also https://docs.aws.amazon.com/sns/latest/api/API_SetEndpointAttributes.html
        let params: [String: Any] = [
            "endpointArn": key,
            "attributes": [
                "CustomUserData": jsonString,
            ],
        ]
        let input = try! AWSSNSSetEndpointAttributesInput(dictionary: params, error: ())

        snsClient.setEndpointAttributes(input) { err in
            if let err = err {
                completion(.failure(.InternalServerError(err)))
                return
            }

            completion(.success(()))
        }
    }

    func unregister(_ key: ProviderKey, completion: @escaping (Result<Void, PushNotificationProviderGatewayError>) -> Void) {
        // NOTE: see also https://docs.aws.amazon.com/sns/latest/api/API_DeleteEndpoint.html
        let params = [
            "endpointArn": key,
        ]
        let input = try! AWSSNSDeleteEndpointInput(dictionary: params, error: ())

        snsClient.deleteEndpoint(input) { err in
            if let err = err {
                completion(.failure(.InternalServerError(err)))
                return
            }

            completion(.success(()))
        }
    }
}
