//
//  NimbleTestHelper.swift
//  InfrastructureTests
//
//  Created by Tasuku Tozawa on 2019/12/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Nimble

func waitUntil(on queue: DispatchQueue, action: @escaping (() -> Void) -> Void) {
    waitUntil(action: action)
}
