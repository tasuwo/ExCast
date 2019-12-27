//
//  Persistable.swift
//  Infrastructure
//
//  Created by Tasuku Tozawa on 2019/12/14.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RealmSwift

protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    static func make(by managedObject: ManagedObject) -> Self
    func asManagedObject() -> ManagedObject
}
