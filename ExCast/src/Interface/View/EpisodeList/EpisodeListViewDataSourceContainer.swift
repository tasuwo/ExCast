//
//  PodcastEpisodeListViewDataSourceContainer.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/05.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import RxDataSources

class EpisodeListViewDataSourceContainer: NSObject {
    weak var episodeListViewModel: EpisodeListViewModel?
    weak var delegate: EpisodeCellDelegate?
    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Episode>> = .init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                       reloadAnimation: .none,
                                                       deleteAnimation: .none),
        configureCell: { [weak self] _, tableView, indexPath, episode in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeListView.identifier, for: indexPath)

            guard let episodeCell = cell as? EpisodeCell else {
                return cell
            }

            episodeCell.setupAppearences()

            episodeCell.episode = episode
            episodeCell.title = episode.meta.title
            episodeCell.pubDate = episode.meta.pubDate
            episodeCell.episodeDescription = episode.meta.subTitle
            episodeCell.duration = episode.meta.duration ?? 0
            episodeCell.currentDuration = {
                if let sec = episode.playback?.playbackPositionSec {
                    return Double(sec)
                } else {
                    return nil
                }
            }()
            episodeCell.delegate = self.delegate

            // NOTE: 再生中のセルを再描画する場合、状態を引き継ぐ
            if let playingEpisodeCell = self.episodeListViewModel?.playingEpisodeCell.value, playingEpisodeCell.indexPath == indexPath {
                episodeCell.playingMarkIconView.isHidden = false
            }

            return cell
        }, canEditRowAtIndexPath: { _, _ in false }
    )
}
