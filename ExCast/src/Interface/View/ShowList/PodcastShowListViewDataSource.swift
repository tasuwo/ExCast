//
//  PodcastShowListViewDataSource.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/09/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources

class PodcastShowListViewDataSourceContainer: NSObject {
    private var thumbnailCache: [IndexPath: UIImage] = [:]
    private var thumbnailDownloadersInProgress: [IndexPath: ThumbnailDownloader] = [:]

    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Podcast>> = .init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                       reloadAnimation: .automatic,
                                                       deleteAnimation: .automatic),
        configureCell: { [weak self] _, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastShowListView.identifier, for: indexPath)

            guard let podcastShowCell = cell as? PodcastShowCellProtocol else {
                return cell
            }

            if let thumbnail = self.thumbnailCache[indexPath] {
                podcastShowCell.layout(artwork: thumbnail,
                                       title: item.show.title,
                                       author: item.show.author)
                return cell
            }

            if let _ = self.thumbnailDownloadersInProgress[indexPath] {
                podcastShowCell.layout(artwork: nil, title: item.show.title, author: item.show.author)
                return cell
            }

            let url = item.show.artwork
            let downloader = ThumbnailDownloader(size: 90)
            downloader.startDownload(by: url) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case let .success(image):
                    self.thumbnailCache[indexPath] = image
                    podcastShowCell.layout(artwork: image,
                                           title: item.show.title,
                                           author: item.show.author)
                    self.thumbnailDownloadersInProgress.removeValue(forKey: indexPath)
                case .failure:
                    break
                }
            }
            self.thumbnailDownloadersInProgress[indexPath] = downloader

            podcastShowCell.layout(artwork: nil, title: item.show.title, author: item.show.author)
            return cell
        }, canEditRowAtIndexPath: { _, _ in true }
    )
}
