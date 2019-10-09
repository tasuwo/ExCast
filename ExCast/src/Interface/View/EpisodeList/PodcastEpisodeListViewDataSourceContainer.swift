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
    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Podcast.Episode>> = .init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                       reloadAnimation: .automatic,
                                                       deleteAnimation: .automatic),
        configureCell: { [weak self] _, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastEpisodeListView.identifier, for: indexPath)

            guard let episodeCell = cell as? PodcastEpisodeCell else {
                return cell
            }

            episodeCell.episode = item
            episodeCell.layout(title: item.title, pubDate: item.pubDate, description: item.subTitle ?? "", duration: item.episodeLength)
            episodeCell.delegate = self.delegate
            // TODO:
            // episodeCell.playingMarkIconView.isHidden = item != self.playingEpisode

            return cell
        }, canEditRowAtIndexPath: { _, _ in false }
    )
}
