//
//  EpisodePlayerModalViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxRelay
import RxSwift

struct PlayerModalViewModel {
    enum ModalChangeTarget {
        case minimize
        case fullscreen
    }

    enum ModalState: Equatable {
        case fullscreen
        case changing(to: ModalChangeTarget, length: Float)
        case mini
        case hide
    }

    enum PanState {
        case changed(lentgh: Float, velocity: Float)
        case ended(length: Float, velocity: Float)
        case none
    }

    var modalState: BehaviorRelay<ModalState> = BehaviorRelay(value: .fullscreen)
    var panState: BehaviorRelay<PanState> = BehaviorRelay(value: .none)

    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init() {
        panState
            .bind(onNext: { [self] panState in
                switch (self.modalState.value, panState) {
                case (.fullscreen, .ended(length: let l, _)) where l > 300:
                    self.modalState.accept(.mini)
                case let (.fullscreen, .ended(_, velocity: v)) where v > 500:
                    self.modalState.accept(.mini)
                case let (.mini, .ended(length: l, velocity: v)) where l < 0 && v < -500:
                    self.modalState.accept(.fullscreen)
                case let (.mini, .ended(length: l, velocity: v)) where l > 0 && v > 500:
                    self.modalState.accept(.hide)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    func didTap() {
        if modalState.value == .mini {
            modalState.accept(.fullscreen)
        }
    }
}
