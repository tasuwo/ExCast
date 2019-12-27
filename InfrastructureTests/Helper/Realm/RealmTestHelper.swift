//
//  Util.swift
//  InfrastructureTests
//
//  Created by Tasuku Tozawa on 2019/12/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RealmSwift

struct RealmTestHelper {
    static func deleteAllRealmObjects(queue: DispatchQueue, done: @escaping () -> Void) {
        queue.async {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
                done()
            }
        }
    }
}
