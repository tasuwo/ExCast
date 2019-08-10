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
    func didChange(feedUrl: String?)
    func didTapSend()
}

class FeedUrlInputView: UIView {
    weak var delegate: FeedUrlInputViewDelegate?

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var textField: MDCTextField!
    
    @IBAction func didChangeFeedUrl(_ sender: Any) {
        self.delegate?.didChange(feedUrl: self.textField.text)
    }
    
    @IBOutlet weak var button: MDCFloatingButton!
    
    @IBAction func didTapButton(_ sender: Any) {
        self.delegate?.didTapSend()
    }

    // MARK: - Initializers

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
        let bundle = Bundle.main

        bundle.loadNibNamed("FeedUrlInputView", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

    private func setupAppearances() {
        // TODO: バグで Interface Builder 上での Dynamic Color が反映されていないのだと思われる。修正されたら外す
        if #available(iOS 13.0, *) {
            self.baseView.backgroundColor = UIColor.systemBackground
        }

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
            self.button.setBackgroundColor(.black)
            self.button.setTitleColor(.white, for: .normal)
            self.textField.backgroundColor = .white
        }

        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.setTitle(NSLocalizedString("FeedUrlInputView.fetchButton", comment: ""), for: .normal)

        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.clearButtonMode = .unlessEditing
        self.textField.placeholder = NSLocalizedString("FeedUrlInputView.placeholder", comment: "")
    }

}
