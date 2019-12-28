//
//  Logger.swift
//  Common
//
//  Created by Tasuku Tozawa on 2019/12/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import SwiftyBeaver

public func debugLog(_ message: Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    LoggerConfigurationManager.shared.beaver.debug(message, file, function, line: line, context: nil)
}

public func infoLog(_ message: Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    LoggerConfigurationManager.shared.beaver.info(message, file, function, line: line, context: nil)
}

public func warnLog(_ message: Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    LoggerConfigurationManager.shared.beaver.warning(message, file, function, line: line, context: nil)
}

public func errorLog(_ message: Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    LoggerConfigurationManager.shared.beaver.error(message, file, function, line: line, context: nil)
}
