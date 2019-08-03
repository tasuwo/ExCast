//
//  UITextView+HtmlBond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

private var textViewHtmlHandle: UInt8 = 1;

extension UITextView {
    var htmlBond: Bond<String> {
        if let bond = objc_getAssociatedObject(self, &textViewHtmlHandle) {
            return bond as! Bond<String>
        } else {
            let bond = Bond<String>() { [unowned self] value in
                DispatchQueue.main.async {
                    self.attributedText = value.toHtmlAttributedString(fontSize: self.font!.pointSize)
                }
            }
            objc_setAssociatedObject(self, &textViewHtmlHandle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UITextView: Bondable {
    var designatedBond: Bond<String> {
        return self.htmlBond
    }
}

