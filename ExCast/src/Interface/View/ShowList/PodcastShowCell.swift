//
//  PodcastShowCell.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol PodcastShowCellProtocol: AnyObject {
    func layout(artwork: UIImage?, title: String, author: String?)
}

class PodcastShowCell: UITableViewCell {
    @IBOutlet var showArtwork: UIImageView!
    @IBOutlet var showTitle: UILabel!
    @IBOutlet var showAuthor: UILabel!

    // MARK: - Lifecyle

    override func layoutSubviews() {
        super.layoutSubviews()

        showArtwork.layer.cornerRadius = 5
        separatorInset = UIEdgeInsets(top: 0, left: 90 + 15 + 10, bottom: 0, right: 0)
    }
}

extension PodcastShowCell: PodcastShowCellProtocol {
    // MARK: - PodcastShowCellProtocol

    func layout(artwork: UIImage?, title: String, author: String?) {
        showArtwork.image = artwork != nil ? artwork : emptyThumbnail(by: .gray)
        showTitle.text = title
        showAuthor.text = author
    }

    private func emptyThumbnail(by color: UIColor) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
            ctx.cgContext.addRect(rect)
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.drawPath(using: .fill)
        }
        return image
    }
}
