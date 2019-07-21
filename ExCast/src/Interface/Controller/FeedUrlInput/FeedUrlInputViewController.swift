//
//  ViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class FeedUrlInputViewController: UIViewController {

    @IBOutlet weak var baseView: FeedUrlInputView!
    private let viewModel: FeedUrlInputViewModel

    // MARK: - Initializer

    init(viewModel: FeedUrlInputViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.baseView.delegate = self

        viewModel.url ->> self.baseView.textField
        viewModel.isValid ->> self.baseView.button

        self.viewModel.setup()
    }

}

extension FeedUrlInputViewController: FeedUrlInputViewDelegate {
    
    // MARK: - FeedUrlInputViewDelegate
    
    func didChange(feedUrl: String?) {
        self.viewModel.url.value = feedUrl ?? ""
    }
    
    func didTapSend() {
        self.viewModel.fetchPodcast() { [weak self] podcast in
            guard let self = self, let podcast = podcast else {
                Swift.print("Podcast 取得失敗")
                return
            }
            
            Swift.print("Podcast 取得成功")
            self.viewModel.store(podcast)
        }
    }
    
}
