//
//  ThumbnailDownloader.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/31.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailDownloader {
    private let size: Int
    private var dataTask: URLSessionDataTask?

    init(size: Int) {
        self.size = size
    }

    func startDownload(by url: URL, at index: IndexPath, completion: @escaping (IndexPath, Result<UIImage, Error>) -> Void) {
        self.dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, let self = self else {
                // TODO:
                abort()
            }

            OperationQueue.main.addOperation {
                guard let image = UIImage(data: data) else {
                    // TODO:
                    abort()
                }

                let size = CGSize(width: self.size, height: self.size)
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                image.draw(in: rect)
                completion(index, Result.success(image))
                UIGraphicsEndImageContext()
            }
        }

        self.dataTask?.resume()
    }

    func cancelDownload() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }

}
