//
//  UILabel+Bond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import ObjectiveC

private var handle: UInt8 = 0;

// MARK: - UILabel

private var labelTextHandle: UInt8 = 0;

extension UILabel {
    var textBond: Bond<String> {
        if let bond = objc_getAssociatedObject(self, &labelTextHandle) {
            return bond as! Bond<String>
        } else {
            let bond = Bond<String>() { [unowned self] value in self.text = value }
            objc_setAssociatedObject(self, &labelTextHandle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UILabel: Bondable {
    var designatedBond: Bond<String> {
        return self.textBond
    }
}

// MARK: - UITextField

extension UITextField {
    var textBond: Bond<String> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<String>
        } else {
            let bond = Bond<String>() { [unowned self] value in self.text = value }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UITextField: Bondable {
    var designatedBond: Bond<String> {
        return self.textBond
    }
}

// MARK: - UIButton

extension UIButton {
    var enableBond: Bond<Bool> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<Bool>
        } else {
            let bond = Bond<Bool>() { [unowned self] value in self.isEnabled = value }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UIButton: Bondable {
    var designatedBond: Bond<Bool> {
        return self.enableBond
    }
}

// MARK: - UIImageView

extension UIImageView {
    var imageBond: Bond<URL?> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<URL?>
        } else {
            let bond = Bond<URL?>() { [unowned self] url in
                guard let url = url else { return }

                DispatchQueue.global(qos: .background).async {
                    guard let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UIImageView: Bondable {
    var designatedBond: Bond<URL?> {
        return self.imageBond
    }
}

// MARK: UISlider

private var sliderValueHandle: UInt8 = 0;

extension UISlider {
    var valueBond: Bond<Float> {
        if let bond = objc_getAssociatedObject(self, &sliderValueHandle) {
            return bond as! Bond<Float>
        } else {
            let bond = Bond<Float>() { [unowned self] value in self.value = value }
            objc_setAssociatedObject(self, &sliderValueHandle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension UISlider: Bondable {
    var designatedBond: Bond<Float> {
        return self.valueBond
    }
}
