//
//  ShowListViewDataSource.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/09/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
// TODO:
import Infrastructure
import RxDataSources

class ShowListViewDataSourceContainer: NSObject {
    private var thumbnailCache: [IndexPath: UIImage] = [:]
    private var thumbnailDownloadersInProgress: [IndexPath: ThumbnailDownloader] = [:]

    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Podcast>> = .init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                       reloadAnimation: .automatic,
                                                       deleteAnimation: .automatic),
        configureCell: { [weak self] _, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: ShowListView.identifier, for: indexPath)

            guard let showCell = cell as? ShowCell else {
                return cell
            }

            showCell.title = item.meta.title
            showCell.author = item.meta.author

            if let thumbnail = self.thumbnailCache[indexPath] {
                showCell.artwork = thumbnail
                return cell
            }

            if let _ = self.thumbnailDownloadersInProgress[indexPath] {
                showCell.artwork = nil
                return cell
            }

            let url = item.meta.artwork
            let downloader = ThumbnailDownloader(size: 90)
            downloader.startDownload(by: url) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case let .success(image):
                    self.thumbnailCache[indexPath] = image
                    showCell.artwork = image
                    self.thumbnailDownloadersInProgress.removeValue(forKey: indexPath)
                case .failure:
                    break
                }
            }
            self.thumbnailDownloadersInProgress[indexPath] = downloader

            showCell.artwork = nil

            return cell
        }, canEditRowAtIndexPath: { _, _ in true }
    )
}
