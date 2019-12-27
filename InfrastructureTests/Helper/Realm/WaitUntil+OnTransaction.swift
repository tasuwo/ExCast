//
//  waitUntil+OnTransaction.swift
//  InfrastructureTests
//
//  Created by Tasuku Tozawa on 2019/12/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Nimble
import RealmSwift

func waitUntil(on queue: DispatchQueue, action: @escaping (Realm, () -> Void) -> Void) {
    waitUntil { done in
        queue.async {
            let realm = try! Realm()
            try! realm.write {
                action(realm, done)
            }
        }
    }
}
