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
    private(set) var values: Array<T>

    var bonds: [BondBox<T>] = []

    init(_ values: Array<T>) {
        self.values = values
    }

    func remove(at index: Int) {
        let target = self.values[index]
        self.values.remove(at: index)

        self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.removeListener?([(index, target)]) }
    }

    func update(at index: Int, value: T) {
        // TODO:
        guard index < self.values.count else { return }

        self.values[index] = value
        self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.updateListener?([(index, value)]) }
    }

    func append(value: T) {
        self.values.append(value)
        let index = self.values.count
        self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.insertListener?([(index, value)]) }
    }

    func set(_ newValues: Array<T>) {
        if newValues.count > self.values.count {
            // TODO: Equalibility
            let updateValues = newValues.enumerated().filter { $0.offset < self.values.count }.map { ($0.offset, $0.element) }
            if !updateValues.isEmpty {
                self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.updateListener?(updateValues) }
            }

            let insertValues = newValues.enumerated().filter { $0.offset >= self.values.count }.map { ($0.offset, $0.element) }
            if !insertValues.isEmpty {
                self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.insertListener?(insertValues) }
            }
        } else {
            // TODO: Equalibility
            if !newValues.isEmpty {
                self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.updateListener?(newValues.enumerated().map { ($0.offset, $0.element) }) }
            }

            let removeValues = self.values.enumerated().filter { $0.offset > newValues.count }.map { ($0.offset, $0.element) }
            if !removeValues.isEmpty {
                self.bonds.forEach { ($0.bond as? ArrayBond<T>)?.removeListener?(removeValues) }
            }
        }

        self.values = newValues
    }
}
