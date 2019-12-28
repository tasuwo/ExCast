//
//  LoggerConfigurationManager.swift
//  Common
//
//  Created by Tasuku Tozawa on 2019/12/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import SwiftyBeaver

public class LoggerConfigurationManager {
    public static let shared = LoggerConfigurationManager()

    public var configuration: LoggerConfiguration {
        didSet {
            SwiftyBeaver.addDestination(configuration.destination.dest)
        }
    }

    let beaver: SwiftyBeaver.Type = SwiftyBeaver.self

    // MARK: - Lifecycle

    private init() {
        configuration = LoggerConfiguration(destination: .console)
        SwiftyBeaver.addDestination(ConsoleDestination())
    }
}
