//
//  PodcastEpisodeListViewDataSourceContainer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/05.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources

class EpisodeListViewDataSourceContainer: NSObject {
    weak var delegate: EpisodeCellDelegate?
    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, EpisodeListViewModel.ListingEpisode>> = .init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                       reloadAnimation: .none,
                                                       deleteAnimation: .none),
        configureCell: { [weak self] _, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeListView.identifier, for: indexPath)

            guard let episodeCell = cell as? EpisodeCell else {
                return cell
            }

            episodeCell.setupAppearences()

            let episode = item.episode
            episodeCell.episode = episode
            episodeCell.title = episode.meta.title
            episodeCell.pubDate = episode.meta.pubDate
            episodeCell.episodeDescription = episode.meta.subTitle
            episodeCell.duration = episode.meta.duration ?? 0
            episodeCell.delegate = self.delegate
            episodeCell.playingMarkIconView.isHidden = item.isPlaying == false

            return cell
        }, canEditRowAtIndexPath: { _, _ in false }
    )
}
