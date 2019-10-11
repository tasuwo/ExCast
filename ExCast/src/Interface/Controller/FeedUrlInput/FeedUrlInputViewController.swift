//
//  ViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/06/30.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import MaterialComponents
import RxCocoa
import RxSwift
import UIKit

class FeedUrlInputViewController: UIViewController {
    typealias Factory = ViewControllerFactory

    @IBOutlet var baseView: FeedUrlInputView!

    private let factory: Factory
    private let viewModel: FeedUrlInputViewModel

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(factory: Factory, viewModel: FeedUrlInputViewModel) {
        self.factory = factory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        baseView.delegate = self
        baseView.textField.rx.text.orEmpty
            .bind(to: viewModel.url)
            .disposed(by: disposeBag)

        viewModel.view = self
        viewModel.isValid.map { $0 }
            .bind(to: baseView.button.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = NSLocalizedString("FeedUrlInputView.title", comment: "")
    }
}

extension FeedUrlInputViewController: FeedUrlInputViewProtocol {
    // MARK: - FeedUrlInputViewProtocol

    func showMessage(_ message: String) {
        let msg = MDCSnackbarMessage()
        msg.text = message
        MDCSnackbarManager.show(msg)
    }

    func didFetchPodcastSuccessfully() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension FeedUrlInputViewController: FeedUrlInputViewDelegate {
    // MARK: - FeedUrlInputViewDelegate

    func didTapSend() {
        viewModel.fetchPodcast()
    }
}
