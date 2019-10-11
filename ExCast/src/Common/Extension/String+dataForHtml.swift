//
//  String+dataForHtml.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

extension String {
    func dataForHtml(withFontSize fontSize: CGFloat) -> Data? {
        if #available(iOS 13.0, *) {
            return String(format: "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize); color: \(UIColor.label.rgbString)\">%@</span>", self).data(using: .utf8)
        } else {
            return String(format: "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize); color: \(UIColor.black.rgbString)\">%@</span>", self).data(using: .utf8)
        }
    }
}

