//
//  ViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import MaterialComponents
import RxCocoa
import RxSwift

class FeedUrlInputViewController: UIViewController {

    @IBOutlet weak var baseView: FeedUrlInputView!
    private let viewModel: FeedUrlInputViewModel
    private var disposeBag = DisposeBag()

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
        self.baseView.textField.rx.text.orEmpty
            .bind(to: self.viewModel.url)
            .disposed(by: self.disposeBag)

        self.viewModel.isValid.map { $0 }
            .bind(to: self.baseView.button.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = NSLocalizedString("FeedUrlInputView.title", comment: "")
    }

}

extension FeedUrlInputViewController: FeedUrlInputViewDelegate {
    
    // MARK: - FeedUrlInputViewDelegate
    
    func didTapSend() {
        self.viewModel.fetchPodcast() { [weak self] podcast in
            let message = MDCSnackbarMessage()

            guard let self = self, let podcast = podcast else {
                message.text = NSLocalizedString("FeedUrlInputView.error.failedToFindPodcast", comment: "")
                MDCSnackbarManager.show(message)
                return
            }


            message.text = String.init(format: NSLocalizedString("FeedUrlInputView.success.fetchPodcast", comment: ""), podcast.show.title)
            MDCSnackbarManager.show(message)

            self.viewModel.store(podcast)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
