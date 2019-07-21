//
//  RootView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/01.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol FeedUrlInputViewDelegate {
    func didChange(feedUrl: String?)
    func didTapSend()
}

class FeedUrlInputView: UIView {
    var delegate: FeedUrlInputViewDelegate?

    @IBOutlet var baseView: UIView!

    @IBOutlet weak var textField: UITextField!
    
    @IBAction func didChangeFeedUrl(_ sender: Any) {
        self.delegate?.didChange(feedUrl: self.textField.text)
    }
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func didTapButton(_ sender: Any) {
        self.delegate?.didTapSend()
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("FeedUrlInputView", owner: self, options: nil)

        self.baseView.frame = self.bounds
        addSubview(baseView)
    }

}
