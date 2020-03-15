//
//  XML.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class XML: NSObject {
    private var rootNode: XmlNode?
    private var activeNode: XmlNode?

    func parse(_ data: Data) -> Result<XmlNode, Error> {
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            return Result.failure(NSError(domain: "", code: -1, userInfo: nil))
        }

        guard let node = rootNode else {
            return Result.failure(NSError(domain: "", code: -1, userInfo: nil))
        }

        return Result.success(node)
    }
}

extension XML: XMLParserDelegate {
    // MARK: - XMLParserDelegate

    func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        let node = XmlNode(name: elementName, attributes: attributeDict)

        if let active = activeNode {
            active.children.append(node)
            node.parent = active
            activeNode = node
        } else {
            activeNode = node
        }

        if rootNode == nil {
            rootNode = node
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        guard let node = activeNode else { return }

        if let previousString = node.value {
            node.value = previousString + string
        } else {
            node.value = string
        }
    }

    func parser(_: XMLParser, didEndElement _: String, namespaceURI _: String?, qualifiedName _: String?) {
        guard let node = activeNode else { return }
        guard let parent = node.parent else { return }

        activeNode = parent
    }
}
