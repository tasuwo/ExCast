//
//  String+toHtmlAttributedString.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func toHtmlAttributedString(fontSize: CGFloat) -> NSAttributedString {
        let modifiedFont: String

        // TODO: アプリ起動中に切り替えるとうまく動作しない
        if #available(iOS 13.0, *) {
            modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize); color: \(UIColor.label.rgbString)\">%@</span>", self)
        } else {
            modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize); color: \(UIColor.black.rgbString)\">%@</span>", self)

        }
        let source = modifiedFont.data(using: .utf8)!
        return try! NSAttributedString(
            data: source,
            options: [
                .documentType:NSAttributedString.DocumentType.html,
                .characterEncoding:String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }
}
