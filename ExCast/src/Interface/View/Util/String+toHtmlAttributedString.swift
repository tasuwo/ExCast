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
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize)\">%@</span>", self)
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
