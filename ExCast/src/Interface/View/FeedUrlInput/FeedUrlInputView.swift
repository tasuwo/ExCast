//
//  RootView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/01.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import UIKit

class FeedUrlInputView: UIView {
    /*
     * IBOutlets
     */

    @IBOutlet var baseView: UIView!
    @IBOutlet var textField: MDCTextField!
    @IBOutlet var button: MDCFloatingButton!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.loadFromNib()
        self.setupAppearances()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.loadFromNib()
        self.setupAppearances()
    }

    // MARK: - Methods

    private func loadFromNib() {
        Bundle.main.loadNibNamed("FeedUrlInputView", owner: self, options: nil)

        baseView.frame = bounds
        addSubview(baseView)
    }

    private func setupAppearances() {
        if #available(iOS 13.0, *) {
            let buttonColor = UIColor { (trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return .lightGray
                } else {
                    return .black
                }
            }
            self.button.setBackgroundColor(buttonColor, for: .normal)
            let titleColor = UIColor { (trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return .black
                } else {
                    return .white
                }
            }
            self.button.setTitleColor(titleColor, for: .normal)

            self.textField.backgroundColor = .systemBackground
            self.textField.textColor = .label
            self.textField.cursorColor = .label
            self.textField.placeholderLabel.textColor = .systemGray
        } else {
            self.button.setBackgroundColor(.black)
            self.button.setTitleColor(.white, for: .normal)
            self.textField.backgroundColor = .white
            self.textField.textColor = .black
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("FeedUrlInputView.fetchButton", comment: ""), for: .normal)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .unlessEditing
        textField.placeholder = NSLocalizedString("FeedUrlInputView.placeholder", comment: "")
    }
}
