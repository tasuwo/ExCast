//
//  waitUntil+OnTransaction.swift
//  InfrastructureTests
//
//  Created by Tasuku Tozawa on 2019/12/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RealmSwift
import Nimble

func waitUntil(on queue: DispatchQueue, with transaction: Realm, action: @escaping (Realm, () -> Void) -> Void) {
    waitUntil(on: queue) { done in
        try! transaction.write {
            action(transaction, done)
        }
    }
}
