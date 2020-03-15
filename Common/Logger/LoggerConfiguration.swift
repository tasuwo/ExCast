//
//  LoggerConfiguration.swift
//  Common
//
//  Created by Tasuku Tozawa on 2019/12/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import SwiftyBeaver

public struct LoggerConfiguration {
    public enum Destination {
        case console
        case file

        var dest: BaseDestination {
            switch self {
            case .console:
                return ConsoleDestination()

            case .file:
                return FileDestination()
            }
        }
    }

    public let destination: Destination

    public init(destination: Destination) {
        self.destination = destination
    }
}
