//
//  PodcastEpisodeListViewDataSourceContainer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/05.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources

class PodcastEpisodeListViewDataSourceContainer: NSObject {
    weak var delegate: PodcastEpisodeCellDelegate?
    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, EpisodeListViewModel.ListingEpisode>> = .init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                       reloadAnimation: .none,
                                                       deleteAnimation: .none),
        configureCell: { [weak self] _, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastEpisodeListView.identifier, for: indexPath)

            guard let episodeCell = cell as? PodcastEpisodeCell else {
                return cell
            }

            let episode = item.episode
            episodeCell.episode = episode
            episodeCell.layout(title: episode.title, pubDate: episode.pubDate, description: episode.subTitle ?? "", duration: episode.episodeLength)
            episodeCell.delegate = self.delegate
            episodeCell.playingMarkIconView.isHidden = item.isPlaying == false

            return cell
        }, canEditRowAtIndexPath: { _, _ in false }
    )
}
