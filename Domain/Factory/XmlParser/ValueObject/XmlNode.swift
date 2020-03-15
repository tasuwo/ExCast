//
//  Node.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

public class XmlNode {
    let name: String
    let attributes: [String: String]
    var value: String? {
        didSet {
            guard let value = self.value else { return }

            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.value = nil
            }
        }
    }

    weak var parent: XmlNode?
    var children: [XmlNode] = []

    init(name: String, attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }
}

extension XmlNode: Equatable {
    // MARK: - Equatable

    public static func == (lhs: XmlNode, rhs: XmlNode) -> Bool {
        lhs.name == rhs.name &&
            lhs.attributes == rhs.attributes &&
            lhs.value == rhs.value
    }
}

precedencegroup XmlNodePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: ComparisonPrecedence
}

infix operator |>: XmlNodePrecedence

// swiftlint:disable:next static_operator
public func |> (node: XmlNode?, childName: String) -> XmlNode? {
    guard let node = node else { return nil }
    return node.children.first { $0.name == childName }
}

infix operator ||>: XmlNodePrecedence

// swiftlint:disable:next static_operator
public func ||> (node: XmlNode?, childName: String) -> [XmlNode]? {
    guard let node = node else { return nil }
    return node.children.filter { $0.name == childName }
}
