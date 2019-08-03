//
//  Date+asFormattedString.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

extension Date {
    func asFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
