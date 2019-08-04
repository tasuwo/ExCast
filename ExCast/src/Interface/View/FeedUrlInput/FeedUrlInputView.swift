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
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.setBackgroundColor(.black)
        self.button.setTitle(NSLocalizedString("FeedUrlInputView.fetchButton", comment: ""), for: .normal)
        self.button.setTitleColor(.white, for: .normal)

        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.clearButtonMode = .unlessEditing
        self.textField.backgroundColor = .white
        self.textField.placeholder = NSLocalizedString("FeedUrlInputView.placeholder", comment: "")
    }

}
