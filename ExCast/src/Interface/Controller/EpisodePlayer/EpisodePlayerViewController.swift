//
//  EpisodePlayerViewController.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/21.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol EpisodePlayerPresenterDelegate: AnyObject {
    func didDismissPlayer()
}

protocol EpisodePlayerPresenter: AnyObject {

    func playingEpisode() -> Podcast.Episode?

    func setDelegate(_ delegate: EpisodePlayerPresenterDelegate)

    func show(show: Podcast.Show, episode: Podcast.Episode)

    func dismiss()

    func minimize()

    func expand()

}

class EpisodePlayerViewController: UIViewController {

    @IBOutlet weak var modalView: EpisodePlayerModalView!

    private unowned var playerPresenter: EpisodePlayerPresenter

    var playingEpisode: Podcast.Episode {
        get {
            return self.informationViewModel.episode
        }
    }

    private var modalViewModel: PlayerModalViewModel!
    private var controllerViewModel: PlayerControllerViewModel!
    private var informationViewModel: PlayerInformationViewModel!

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(presenter: EpisodePlayerPresenter,
         viewModel: PlayerControllerViewModel,
         informationViewModel: PlayerInformationViewModel,
         modalViewModel: PlayerModalViewModel) {
        self.playerPresenter = presenter
        self.controllerViewModel = viewModel
        self.informationViewModel = informationViewModel
        self.modalViewModel = modalViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate

        self.modalView.delegate = self
        self.modalView.seekBar.delegate = self
        self.modalView.playbackButtons.delegate = self

        // Bind

        self.modalViewModel.modalState
            .bind(onNext: { [unowned self] state in
                switch state {
                case .fullscreen:
                    self.modalView.expand()
                case .mini:
                    self.modalView.minimize()
                case .hide:
                    self.shouldDismiss()
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        self.bindEpisode()
    }

    // MARK: - Methods

    func reload(controllerViewModel: PlayerControllerViewModel,
                informationViewModel: PlayerInformationViewModel) {
        self.controllerViewModel = nil
        self.controllerViewModel = controllerViewModel
        self.informationViewModel = nil
        self.informationViewModel = informationViewModel

        self.bindEpisode()
    }

    private func bindEpisode() {
        let length = self.controllerViewModel.episode.episodeLength
        self.modalView.seekBar.bar.maximumValue = CGFloat(length)

        // Bind

        self.informationViewModel.showTitle
            .bind(to: self.modalView.showTitleLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.informationViewModel.episodeTitle
            .bind(to: self.modalView.showTitleLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.informationViewModel.thumbnail
            .compactMap({ $0 })
            .compactMap({ try? Data(contentsOf: $0) })
            .compactMap({ UIImage(data: $0) })
            .bind(to: self.modalView.thumbnailImageView.rx.image)
            .disposed(by: self.disposeBag)

        self.controllerViewModel.isPrepared
            .bind(to: self.modalView.playbackButtons.playbackButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        self.controllerViewModel.isPrepared
            .bind(to: self.modalView.playbackButtons.forwardSkipButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        self.controllerViewModel.isPrepared
            .bind(to: self.modalView.playbackButtons.backwardSkipButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        self.controllerViewModel.isPlaying
            .compactMap({ isPlaying -> UIImage? in
                if isPlaying {
                    return UIImage(named: "player_pause")
                } else {
                    return UIImage(named: "player_playback")
                }
            })
            .bind(to: self.modalView.playbackButtons.playbackButton.rx.image(for: .normal))
            .disposed(by: self.disposeBag)
        self.controllerViewModel.displayCurrentTime
            .compactMap({ $0.asTimeString() })
            .bind(to: self.modalView.seekBar.currentTimeLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.controllerViewModel.displayCurrentTime
            .compactMap({ (Float($0) - length).asTimeString() })
            .bind(to: self.modalView.seekBar.remainingTimeLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.controllerViewModel.displayCurrentTime
            .map({ CGFloat($0) })
            .bind(onNext: { [weak self] time in self?.modalView.seekBar.bar.value = time })
            .disposed(by: self.disposeBag)

        self.controllerViewModel.setup()
    }

}

extension EpisodePlayerViewController: EpisodePlayerPlaybackButtonsDelegate {

    // MARK: EpisodePlayerPlaybackButtonsDelegate

    func didTapPlaybackButton() {
        self.controllerViewModel.playback()
    }

    func didTapSkipForwardButton() {
        self.controllerViewModel.skipForward()
    }

    func didTapSkipBackwardButton() {
        self.controllerViewModel.skipBackward()
    }

}

extension EpisodePlayerViewController: EpisodePlayerSeekBarContainerDelegate {

    func didStartSeek() {
        self.controllerViewModel.isSliderGrabbed.accept(true)
    }

    func didEndSeek() {
        self.controllerViewModel.isSliderGrabbed.accept(false)
    }

    func didChangeSeekValue(to time: TimeInterval) {
        self.controllerViewModel.displayCurrentTime.accept(time)
    }

}

extension EpisodePlayerViewController: EpisodePlayerModalViewDelegate {

    // MARK: - EpisodePlayerModalViewDelegate

    func shouldDismiss() {
        self.playerPresenter.dismiss()
    }

    func shouldMinimize() {
        self.playerPresenter.minimize()
    }

    func shouldExpand() {
        self.playerPresenter.expand()
    }

    func didTap() {
        self.modalViewModel.didTap()
    }

    func didPanned(distance: Float, velocity: Float) {
        self.modalViewModel.panState.accept(.changed(lentgh: distance, velocity: velocity))
    }

    func didEndPanned(distance: Float, velocity: Float) {
        self.modalViewModel.panState.accept(.ended(length: distance, velocity: velocity))
        self.modalViewModel.panState.accept(.none)
    }

    func didTapMinimizeButton() {
        self.modalViewModel.modalState.accept(.mini)
    }

}
