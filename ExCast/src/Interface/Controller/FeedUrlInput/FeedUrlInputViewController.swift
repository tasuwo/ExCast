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
    // MARK: - Type Aliases

    typealias Factory = ViewControllerFactory
    typealias Dependency = FeedUrlInputViewModelType

    // MARK: Properties

    private let factory: Factory
    private let viewModel: FeedUrlInputViewModelType

    private var disposeBag = DisposeBag()

    // MARK: - IBOutlets

    @IBOutlet var baseView: FeedUrlInputView!

    // MARK: - Initializer

    init(factory: Factory, viewModel: FeedUrlInputViewModelType) {
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

        self.bind(to: self.viewModel)
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

extension FeedUrlInputViewController {
    // MARK: - Binding

    func bind(to dependency: Dependency) {
        // MARK: Outputs

        dependency.outputs.isFeedUrlValid
            .drive(self.baseView.button.rx.isEnabled)
            .disposed(by: self.disposeBag)

        dependency.outputs.messageDisplayed
            .emit(onNext: { message in
                MDCSnackbarManager.show(MDCSnackbarMessage(text: message))
            })
            .disposed(by: self.disposeBag)

        // MARK: Inputs

        self.baseView.textField.rx.text
            .orEmpty
            .bind(to: dependency.inputs.feedUrl)
            .disposed(by: self.disposeBag)

        self.baseView.button.rx.tap
            .asSignal()
            .emit(to: dependency.inputs.podcastFetched)
            .disposed(by: self.disposeBag)
    }
}
