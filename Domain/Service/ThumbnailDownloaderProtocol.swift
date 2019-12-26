//
//  ThumbnailDownloaderProtocol.swift
//  Domain
//
//  Created by Tasuku Tozawa on 2019/12/08.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

public enum ThumbnailDownloadError: Error {
    case failedToFetchData
    case invalidUrl
}

public protocol ThumbnailDowloaderProtocol {
    func startDownload(by url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
    func cancelDownload()
}
