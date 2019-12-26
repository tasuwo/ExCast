//
//  ThumbnailDownloader.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/31.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import Foundation
import UIKit

public class ThumbnailDownloader: ThumbnailDowloaderProtocol {
    private let size: Int
    private var dataTask: URLSessionDataTask?

    public init(size: Int) {
        self.size = size
    }

    public func startDownload(by url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { fatalError() }
            guard let data = data else {
                completion(Result.failure(ThumbnailDownloadError.failedToFetchData))
                return
            }

            OperationQueue.main.addOperation {
                guard let image = UIImage(data: data) else {
                    completion(Result.failure(ThumbnailDownloadError.invalidUrl))
                    return
                }

                let size = CGSize(width: self.size, height: self.size)
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                image.draw(in: rect)
                completion(Result.success(image))
                UIGraphicsEndImageContext()
            }
        }

        dataTask?.resume()
    }

    public func cancelDownload() {
        dataTask?.cancel()
        dataTask = nil
    }
}
