//
//  Data+makeHtmlString.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

extension Data {
    func makeHtmlString() -> NSAttributedString? {
        return try? NSAttributedString(
            data: self,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ],
            documentAttributes: nil
        )
    }
}
