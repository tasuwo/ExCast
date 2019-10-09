//
//  RootView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/01.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import UIKit

protocol FeedUrlInputViewDelegate: AnyObject {
    func didTapSend()
}

class FeedUrlInputView: UIView {
    weak var delegate: FeedUrlInputViewDelegate?

    @IBOutlet var baseView: UIView!

    @IBOutlet var textField: MDCTextField!

    @IBOutlet var button: MDCFloatingButton!

    @IBAction func didTapButton(_: Any) {
        delegate?.didTapSend()
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setupAppearances()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
        setupAppearances()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("FeedUrlInputView", owner: self, options: nil)

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
            self.textField.textColor = .white
            self.textField.cursorColor = .label
            self.textField.placeholderLabel.textColor = .label
        } else {
            button.setBackgroundColor(.black)
            button.setTitleColor(.white, for: .normal)
            textField.backgroundColor = .white
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("FeedUrlInputView.fetchButton", comment: ""), for: .normal)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .unlessEditing
        textField.placeholder = NSLocalizedString("FeedUrlInputView.placeholder", comment: "")
    }
}
