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

/// @mockable
public protocol ThumbnailDownloaderProtocol {
    func startDownload(by url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
    func cancelDownload()
}
