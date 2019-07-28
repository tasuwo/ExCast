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

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    mutating func setup() {
        self.modalState.value = .fullscreen
        self.panState.value = .none

        self.panBond = Bond() { [self] panState in
            switch (self.modalState.value, panState) {
            case (.fullscreen, .changed(lentgh: let l, velocity: _)) where l == 0:
                self.modalState.value = .changing(to: .minimize, length: 0)
            case (.mini, .changed(lentgh: let l, velocity: _)) where l == 0:
                self.modalState.value = .changing(to: .fullscreen, length: 0)

            case (.changing(to: .minimize, length: _), .ended(length: let l, velocity: _)) where l > 1000:
                self.modalState.value = .mini
            case (.changing(to: .minimize, length: _), .ended(length: _, velocity: let v)) where v > 1000:
                self.modalState.value = .mini

            case (.changing(to: .fullscreen, length: _), .ended(length: let l, velocity: _)) where l > -1000:
                self.modalState.value = .mini
            case (.changing(to: .fullscreen, length: _), .ended(length: _, velocity: let v)) where v > 1000:
                self.modalState.value = .mini

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
