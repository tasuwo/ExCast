//
//  XMLTests.swift
//  ExCastTests
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

@testable import Domain
import XCTest

class XMLTests: XCTestCase {
    override func setUp() {}

    override func tearDown() {}

    func testParseNode() {
        let str = "<Root attr1=\"val1\" attr2=\"val2\">val</Root>"
        let parser = XML()

        let result = parser.parse(str.data(using: .utf8)!)

        switch result {
        case let .success(root):
            XCTAssertEqual(root.name, "Root")
            XCTAssertEqual(root.attributes, ["attr1": "val1", "attr2": "val2"])
            XCTAssertEqual(root.value, "val")
            XCTAssertEqual(root.children.count, 0)
            XCTAssertNil(root.parent)
        case .failure:
            XCTFail()
        }
    }

    func testParseNodes() {
        let str = """
        <ResultSet>
            <Result>
                <Hit index=\"1\">
                    <Name>Item1</Name>
                </Hit>
                <Hit index=\"2\">
                    <Name>Item2</Name>
                </Hit>
            </Result>
        </ResultSet>
        """
        let parser = XML()

        let result = parser.parse(str.data(using: .utf8)!)

        switch result {
        case let .success(root):
            XCTAssertEqual(root.name, "ResultSet")
            XCTAssertEqual(root.attributes, [:])
            XCTAssertNil(root.value)
            XCTAssertEqual(root.children.count, 1)
            XCTAssertNil(root.parent)

            let result = root.children.first!
            XCTAssertEqual(result.name, "Result")
            XCTAssertEqual(result.attributes, [:])
            XCTAssertNil(result.value)
            XCTAssertEqual(result.children.count, 2)
            XCTAssertEqual(result.parent!, root)

            let hit1 = result.children[0]
            XCTAssertEqual(hit1.name, "Hit")
            XCTAssertEqual(hit1.attributes, ["index": "1"])
            XCTAssertNil(hit1.value)
            XCTAssertEqual(hit1.children.count, 1)
            XCTAssertEqual(hit1.parent!, result)

            let name1 = hit1.children[0]
            XCTAssertEqual(name1.name, "Name")
            XCTAssertEqual(name1.attributes, [:])
            XCTAssertEqual(name1.value, "Item1")
            XCTAssertEqual(name1.children.count, 0)
            XCTAssertEqual(name1.parent!, hit1)

            let hit2 = result.children[1]
            XCTAssertEqual(hit2.name, "Hit")
            XCTAssertEqual(hit2.attributes, ["index": "2"])
            XCTAssertNil(hit2.value)
            XCTAssertEqual(hit2.children.count, 1)
            XCTAssertEqual(hit2.parent!, result)

            let name2 = hit2.children[0]
            XCTAssertEqual(name2.name, "Name")
            XCTAssertEqual(name2.attributes, [:])
            XCTAssertEqual(name2.value, "Item2")
            XCTAssertEqual(name2.children.count, 0)
            XCTAssertEqual(name2.parent!, hit2)
        case .failure:
            XCTFail()
        }
    }

    func testGetChildNodeByOperator() {
        let str = """
        <ResultSet>
            <Result>
                <Hit index=\"1\">
                    <Name>Item1</Name>
                </Hit>
                <Hit index=\"2\">
                    <Name>Item2</Name>
                </Hit>
            </Result>
        </ResultSet>
        """
        let parser = XML()

        let result = parser.parse(str.data(using: .utf8)!)

        switch result {
        case let .success(root):
            let result = root |> "Result"
            XCTAssertEqual(result?.name, "Result")
            XCTAssertEqual(result?.attributes, [:])
            XCTAssertNil(result?.value)
            XCTAssertEqual(result?.children.count, 2)
            XCTAssertEqual(result?.parent!, root)

            let hit1 = root |> "Result" |> "Hit"
            XCTAssertEqual(hit1?.name, "Hit")
            XCTAssertEqual(hit1?.attributes, ["index": "1"])
            XCTAssertNil(hit1?.value)
            XCTAssertEqual(hit1?.children.count, 1)
            XCTAssertEqual(hit1?.parent!, result)

            let name1 = root |> "Result" |> "Hit" |> "Name"
            XCTAssertEqual(name1?.name, "Name")
            XCTAssertEqual(name1?.attributes, [:])
            XCTAssertEqual(name1?.value, "Item1")
            XCTAssertEqual(name1?.children.count, 0)
            XCTAssertEqual(name1?.parent!, hit1)
        case .failure:
            XCTFail()
        }
    }

    func testGetChildNodesByOperator() {
        let str = """
        <ResultSet>
            <Result>
                <Hit index=\"1\">
                    <Name>Item1</Name>
                </Hit>
                <Hit index=\"2\">
                    <Name>Item2</Name>
                </Hit>
            </Result>
        </ResultSet>
        """
        let parser = XML()

        let result = parser.parse(str.data(using: .utf8)!)

        switch result {
        case let .success(root):
            let hits = root |> "Result" ||> "Hit"

            let hit1 = hits?[0]
            XCTAssertEqual(hit1?.name, "Hit")
            XCTAssertEqual(hit1?.attributes, ["index": "1"])
            XCTAssertNil(hit1?.value)
            XCTAssertEqual(hit1?.children.count, 1)
            XCTAssertEqual(hit1?.parent, root |> "Result")

            let hit2 = hits?[1]
            XCTAssertEqual(hit2?.name, "Hit")
            XCTAssertEqual(hit2?.attributes, ["index": "2"])
            XCTAssertNil(hit2?.value)
            XCTAssertEqual(hit2?.children.count, 1)
            XCTAssertEqual(hit2?.parent, root |> "Result")
        case .failure:
            XCTFail()
        }
    }

    func testParseHtmlString() {
        let str = """
        <description>&lt;p&gt;test&lt;/p&gt;</description>
        """

        let parser = XML()

        let result = parser.parse(str.data(using: .utf8)!)

        switch result {
        case let .success(root):
            XCTAssertEqual(root.value, "<p>test</p>")
        case .failure:
            XCTFail()
        }
    }

    func testParseStringWithNewLines() {
        let str = """
        <description>
        test1
        test2
        test3
        </description>
        """

        let parser = XML()

        let result = parser.parse(str.data(using: .utf8)!)

        switch result {
        case let .success(root):
            XCTAssertEqual(root.value, "\ntest1\ntest2\ntest3\n")
        case .failure:
            XCTFail()
        }
    }
}
