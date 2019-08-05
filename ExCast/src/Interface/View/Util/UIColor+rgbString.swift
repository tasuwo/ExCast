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
        var r: CGFloat = -1
        var g: CGFloat = -1
        var b: CGFloat = -1
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return [r, g, b].reduce("") { res, value in
            let intval = Int(round(value * 255))
            return res + (NSString(format: "%02X", intval) as String)
        }
    }

}
