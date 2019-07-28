//
//  Doublt+asTimeString.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/28.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

extension Double {
    func asTimeString() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute,.hour,.second]
        formatter.zeroFormattingBehavior = .pad
        let data = formatter.string(from: self)
        return data
    }
}
