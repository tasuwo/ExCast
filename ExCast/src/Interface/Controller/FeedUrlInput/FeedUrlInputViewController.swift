//
//  ViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // TODO: 多言語対応
        self.title = "Add New Podcast"
    }

}

extension FeedUrlInputViewController: FeedUrlInputViewDelegate {
    
    // MARK: - FeedUrlInputViewDelegate
    
    func didChange(feedUrl: String?) {
        self.viewModel.url.value = feedUrl ?? ""
    }
    
    func didTapSend() {
        self.viewModel.fetchPodcast() { [weak self] podcast in
            let message = MDCSnackbarMessage()

            guard let self = self, let podcast = podcast else {
                message.text = "Could not find podcast feed at this url."
                MDCSnackbarManager.show(message)
                return
            }

            message.text = "New podcast feed \"\(podcast.show.title)\" is successfully added."
            MDCSnackbarManager.show(message)

            self.viewModel.store(podcast)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
