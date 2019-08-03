//
//  EpisodePlayerModalViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//


struct EpisodePlayerModalViewModel {

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

    var modalState: Dynamic<ModalState> = Dynamic(.fullscreen)
    var panState: Dynamic<PanState> = Dynamic(.none)

    private var panBond: Bond<PanState>!

    // MARK: - Methods

    mutating func setup() {
        self.panState.value = .none

        self.panBond = Bond() { [self] panState in
            switch (self.modalState.value, panState) {
            case (.fullscreen, .ended(length: let l, _)) where l > 300:
                self.modalState.value = .mini
            case (.fullscreen, .ended(_, velocity: let v)) where v > 500:
                self.modalState.value = .mini
            case (.mini, .ended(length: let l, velocity: let v)) where l < 0 && v < -500:
                self.modalState.value = .fullscreen
            case (.mini, .ended(length: let l, velocity: let v)) where l > 0 && v > 500:
                self.modalState.value = .hide

            default:
                break
            }
        }
        self.panBond.bind(self.panState)
    }

    func didTap() {
        if self.modalState.value == .mini {
            self.modalState.value = .fullscreen
        }
    }

}
