//
//  Float+asTimeString.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

extension Float {
    func asTimeString() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute,.hour,.second]
        formatter.zeroFormattingBehavior = .pad
        let data = formatter.string(from: Double(self))
        return data
    }
}
