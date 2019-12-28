//
//  ShowCell.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class ShowCell: UITableViewCell {
    public var artwork: UIImage? {
        set {
            showArtwork.image = newValue != nil ? newValue : emptyThumbnail(by: .gray)
        }
        get {
            return showArtwork.image
        }
    }

    public var title: String? {
        set {
            showTitle.text = newValue
        }
        get {
            return showTitle.text
        }
    }

    public var author: String? {
        set {
            showAuthor.text = newValue
        }
        get {
            return showAuthor.text
        }
    }

    // MARK: - IBOutlets

    @IBOutlet var showArtwork: UIImageView!
    @IBOutlet var showTitle: UILabel!
    @IBOutlet var showAuthor: UILabel!

    // MARK: - Lifecyle

    override func layoutSubviews() {
        super.layoutSubviews()

        showArtwork.layer.cornerRadius = 5
        separatorInset = UIEdgeInsets(top: 0, left: 90 + 15 + 10, bottom: 0, right: 0)
    }

    // MARK: - Methods

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
