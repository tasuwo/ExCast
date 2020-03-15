//
//  UIColor+rgbString.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/06.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

extension UIColor {
    var rgbString: String {
        var red: CGFloat = -1
        var green: CGFloat = -1
        var blue: CGFloat = -1
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [red, green, blue].reduce(into: "") { res, value in
            let intval = Int(round(value * 255))
            return res += (NSString(format: "%02X", intval) as String)
        }
    }
}
