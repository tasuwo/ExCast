//
//  EpisodeListCell.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

protocol PodcastEpisodeCellDelegate: AnyObject {
    func podcastEpisodeCell(_ cell: UITableViewCell, didSelect episode: Podcast.Episode)
}

protocol PodcastEpisodeCellProtocol {
    func layout(title: String, pubDate: Date?, description: String, duration: Float)
}

class PodcastEpisodeCell: UITableViewCell {
    @IBOutlet var pubDate: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var episodeDescription: UILabel!
    @IBOutlet var length: UILabel!
    @IBOutlet var informationButton: UIButton!
    @IBOutlet var playingMarkIconView: UIImageView!

    var episode: Podcast.Episode?
    weak var delegate: PodcastEpisodeCellDelegate?

    @IBAction func didTapInformationIcon(_: UIButton) {
        guard let episode = self.episode else { return }
        delegate?.podcastEpisodeCell(self, didSelect: episode)
    }
}

extension PodcastEpisodeCell: PodcastEpisodeCellProtocol {
    func layout(title: String, pubDate: Date?, description: String, duration: Float) {
        self.title.text = title
        self.pubDate.text = pubDate?.asFormattedString()
        episodeDescription.text = description
        length.text = duration.asTimeString()

        informationButton.setTitle(NSLocalizedString("PodcastEpisodeListView.cell.detail", comment: ""), for: .normal)
        playingMarkIconView.image = generatePlayingMark()
        playingMarkIconView.isHidden = true
    }

    private func generatePlayingMark() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let image = renderer.image { ctx in
            let circle = UIBezierPath(arcCenter: CGPoint(x: 5, y: 5), radius: 2.5, startAngle: 0, endAngle: CGFloat(Double.pi) * 2, clockwise: true)
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.addPath(circle.cgPath)
            ctx.cgContext.drawPath(using: .fill)
        }
        return image
    }
}
