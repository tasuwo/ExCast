//
//  EpisodeDetailView+Rx.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/12.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: EpisodeDetailView {
    public var thumbnail: Binder<UIImage?> {
        Binder(base) { view, value in
            view.thumbnail = value
        }
    }

    public var publishDate: Binder<Date?> {
        Binder(base) { view, value in
            view.publishDate = value
        }
    }

    public var title: Binder<String> {
        Binder(base) { view, value in
            view.title = value
        }
    }

    public var duration: Binder<Double> {
        Binder(base) { view, value in
            view.duration = value
        }
    }

    public var episodeDescripiton: Binder<String> {
        Binder(base) { view, value in
            view.episodeDescription = value
        }
    }
}
