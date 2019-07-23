//
//  Dynamic.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

// A task defined by a closure
// View updated, model changed, or an action performed...
typealias Listener<T> = (T) -> Void

// Dynamic の変更時に Listener を呼び出す
class Bond<T> {
    var listener: Listener<T>
    
    init(_ listener: @escaping Listener<T>) {
        self.listener = listener
    }
    
    func bind(_ dynamic: Dynamic<T>) {
        dynamic.bonds.append(BondBox(self))
    }
}

// Dynamic に Bond を強参照させないためのラッパー
class BondBox<T> {
    weak var bond: Bond<T>?
    init(_ b: Bond<T>) { bond = b }
}

// データの変更を監視し、変更時にはそれを伝播する
class Dynamic<T> {
    var value: T {
        didSet {
            bonds.forEach { $0.bond?.listener(value) }
        }
    }

    var bonds: [BondBox<T>] = []
    private var bond: Bond<T>! = nil
    private var dynamics: [Dynamic<String>] = []

    init(_ v: T) {
        value = v
    }

    func map(_ f: @escaping (T) -> String) -> Dynamic<String> {
        let dynamic = Dynamic<String>(f(self.value))

        self.dynamics.append(dynamic)
        self.bond = Bond<T>() { v in
            dynamic.value = f(v)
        }
        self.bonds.append(BondBox(bond))

        return dynamic
    }
}
