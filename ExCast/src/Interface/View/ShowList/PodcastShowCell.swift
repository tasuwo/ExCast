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
    
    @IBOutlet weak var showArtwork: UIImageView!
    @IBOutlet weak var showTitle: UILabel!
    @IBOutlet weak var showAuthor: UILabel!

    // MARK: - Lifecyle

    override func layoutSubviews() {
        super.layoutSubviews()

        self.showArtwork.layer.cornerRadius = 5
        self.separatorInset = UIEdgeInsets(top: 0, left: 90+15+10, bottom: 0, right: 0)
    }
}


extension PodcastShowCell: PodcastShowCellProtocol {
    
    // MARK: - PodcastShowCellProtocol
    
    func layout(artwork: UIImage?, title: String, author: String?) {
        self.showArtwork.image = artwork != nil ? artwork : generateSimpleColorUIImage(color: .gray)
        self.showTitle.text = title
        self.showAuthor.text = author
    }

    private func generateSimpleColorUIImage(color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
