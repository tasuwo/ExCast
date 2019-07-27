//
//  EpisodePlayerModalViewModel.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/27.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//


struct EpisodePlayerModalViewModel {

    enum State {
        case fullscreen
        case mini
        case hide
    }

    var state: Dynamic<State>

    // MARK: - Initializers

    init() {
        self.state = Dynamic(.fullscreen)
    }

    // MARK: - Methods

    func toggle() {
        switch self.state.value {
        case .fullscreen:
            self.state.value = .mini
        case .mini:
            self.state.value = .fullscreen
        case .hide:
            // NOP:
            break
        }
    }

    func expand() {
        if self.state.value == .mini {
            self.state.value = .fullscreen
        }
    }

}
