//
//  Bondable.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

protocol Bondable {
    associatedtype BondType
    var designatedBond: Bond<BondType> { get }
}

precedencegroup BondPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: ComparisonPrecedence
}

infix operator ->>: BondPrecedence

func ->> <T>(left: Dynamic<T>, right: Bond<T>) {
    right.bind(left)
}

func ->> <T, U: Bondable>(left: Dynamic<T>, right: U) where U.BondType == T {
    left ->> right.designatedBond
}

func ->> <T>(left: DynamicArray<T>, right: ArrayBond<T>) {
    right.bind(left)
}
