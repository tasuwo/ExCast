//
//  MDCSlider+Bond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/04.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents

private var sliderValueHandle: UInt8 = 0;

extension MDCSlider {
    var valueBond: Bond<Double> {
        if let bond = objc_getAssociatedObject(self, &sliderValueHandle) {
            return bond as! Bond<Double>
        } else {
            let bond = Bond<Double>() { [unowned self] value in self.value = CGFloat(value) }
            objc_setAssociatedObject(self, &sliderValueHandle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension MDCSlider: Bondable {
    var designatedBond: Bond<Double> {
        return self.valueBond
    }
}
