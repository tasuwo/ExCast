//
//  PushNotificationProviderImpl.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import AWSSNS

class PushNotificationProviderGatewayImpl: PushNotificationProviderGateway {
    let snsClient: AWSSNS
    let applicationArn: String

    init(snsClient: AWSSNS, applicationArn: String) {
        self.snsClient = snsClient
        self.applicationArn = applicationArn
    }

    func register(_ token: Data) {
        let tokenString = token.map { String(format: "%.2hhx", $0) }.joined()
        Swift.print(tokenString)

        let params = [
            "token": tokenString,
            "customUserData": "{\"lang\":\"ja\"}",
            "platformApplicationArn": applicationArn
        ]
        let input = try! AWSSNSCreatePlatformEndpointInput(dictionary: params, error: ())

        snsClient.createPlatformEndpoint(input).continueWith(executor: .mainThread()) { task in
            if let err = task.error {
                Swift.print(err)
                return nil
            }

            // TODO:
            Swift.print(task.result)
            return nil
        }
    }

    func unregister(_ token: Date) {

    }

}
