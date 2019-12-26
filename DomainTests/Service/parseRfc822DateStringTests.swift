//
//  ExCastTests.swift
//  ExCastTests
//
//  Created by Tasuku Tozawa on 2019/07/19.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import XCTest
@testable import Domain

class parseRfc822DateStringTests: XCTestCase {
    var formatter: ISO8601DateFormatter!

    override func setUp() {
        formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
    }

    override func tearDown() {
        formatter = nil
    }

    func testParseFullRfc822StringWithGmt() {
        let str = "Wed, 17 Jul 2019 01:00:00 GMT"

        let result = parseRfc822DateString(str)

        XCTAssertEqual(result, formatter.date(from: "2019-07-17T01:00:00+00:00"))
    }

    func testParseFullRfc822StringWithPositiveLocalZone() {
        let str = "Wed, 17 Jul 2019 01:00:00 +0700"

        let result = parseRfc822DateString(str)

        XCTAssertEqual(result, formatter.date(from: "2019-07-17T01:00:00+07:00"))
    }

    func testParseFullRfc822StringWithNegativeLocalZone() {
        let str = "Wed, 17 Jul 2019 01:00:00 -0700"

        let result = parseRfc822DateString(str)

        XCTAssertEqual(result, formatter.date(from: "2019-07-17T01:00:00-07:00"))
    }

    func testParseDayOmittedRfc822String() {
        let str = "17 Jul 2019 01:00:00 -0700"

        let result = parseRfc822DateString(str)

        XCTAssertEqual(result, formatter.date(from: "2019-07-17T01:00:00-07:00"))
    }
}
