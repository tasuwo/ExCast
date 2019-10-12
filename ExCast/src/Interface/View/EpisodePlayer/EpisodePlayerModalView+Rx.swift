//
//  EpisodePlayerModalView+Rx.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/12.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: EpisodePlayerModalView {
    public var showTitle: Binder<String> {
        return Binder(base) { view, value in
            view.showTitle = value
        }
    }

    public var episodeTitle: Binder<String> {
        return Binder(base) { view, value in
            view.episodeTitle = value
        }
    }

    public var thumbnail: Binder<UIImage?> {
        return Binder(base) { view, value in
            view.thumbnail = value
        }
    }

    public var duration: Binder<Double> {
        return Binder(base) { view, value in
            view.duration = value
        }
    }

    public var currentTime: Binder<Double> {
        return Binder(base) { view, value in
            view.currentTime = value
        }
    }

    public var isPlaybackEnabled: Binder<Bool> {
        return Binder(base) { view, value in
            view.isPlaybackEnabled = value
        }
    }

    public var isPlaying: Binder<Bool> {
        return Binder(base) { view, value in
            view.isPlaying = value
        }
    }
}
