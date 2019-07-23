//
//  ArrayBond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

typealias InsertListener<T> = ([(Int, T)]) -> Void
typealias RemoveListener<T> = ([(Int, T)]) -> Void
typealias UpdateListener<T> = ([(Int, T)]) -> Void

class ArrayBond<T>: Bond<T> {
    var insertListener: InsertListener<T>?
    var removeListener: RemoveListener<T>?
    var updateListener: UpdateListener<T>?

    init(insert: @escaping InsertListener<T>, remove: @escaping RemoveListener<T>, update: @escaping UpdateListener<T>) {
        self.insertListener = insert
        self.removeListener = remove
        self.updateListener = update
        super.init({_ in })
    }

    func bind(_ dynamic: DynamicArray<T>) {
        dynamic.bonds.append(BondBox(self))
    }

    func release(_ dynamic: DynamicArray<T>) {
        dynamic.bonds.removeAll(where: { [unowned self] box in box.bond === self })
    }
}

typealias Id<T: Equatable, S: Hashable> = (T) -> S

class DynamicArray<T> {
    private(set) var value: Array<T>

    var bonds: [BondBox<T>] = []

    init(_ value: Array<T>) {
        self.value = value
    }

    func remove(at index: Int) {
        let target = self.value[index]
        self.value.remove(at: index)

        self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.removeListener?([(index, target)]) }
    }

    func update(at index: Int, value: T) {
        // TODO:
        guard index < self.value.count else { return }

        self.value[index] = value
        self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.updateListener?([(index, value)]) }
    }

    func append(value: T) {
        self.value.append(value)
        let index = self.value.count
        self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.insertListener?([(index, value)]) }
    }

    func set(_ value: Array<T>) {
        let oldValue = self.value
        self.value = value
        self.bonds.forEach { [unowned self] box in
            if oldValue.isEmpty == false {
                let oldSets = oldValue.enumerated().map { ($0.offset, $0.element) }
                (box.bond as? ArrayBond<T>)?.removeListener?(oldSets)
            }

            let sets = self.value.enumerated().map { ($0.offset, $0.element) }
            (box.bond as? ArrayBond<T>)?.insertListener?(sets)
        }
    }
}
