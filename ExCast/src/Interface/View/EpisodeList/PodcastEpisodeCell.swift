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
    func layout(title: String, pubDate: Date?, description: String, duration: String?)
}

class PodcastEpisodeCell: UITableViewCell {
    
    @IBOutlet weak var pubDate: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var episodeDescription: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var informationButton: UIButton!
    @IBOutlet weak var playingMarkIconView: UIImageView!

    var episode: Podcast.Episode?
    weak var delegate: PodcastEpisodeCellDelegate?

    @IBAction func didTapInformationIcon(_ sender: UIButton) {
        guard let episode = self.episode else { return }
        self.delegate?.podcastEpisodeCell(self, didSelect: episode)
    }
}

extension PodcastEpisodeCell: PodcastEpisodeCellProtocol {
    func layout(title: String, pubDate: Date?, description: String, duration: String?) {
        self.title.text = title

        if let date = pubDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            self.pubDate.text = formatter.string(from: date)
        }

        // TODO:
        let str = try! NSAttributedString(data: description.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
        self.episodeDescription.text = str

        if let length = duration {
            self.length.text = String(length)
        } else {
            self.length.text = ""
        }

        self.informationButton.setTitle("Detail", for: .normal)
        self.playingMarkIconView.image = generatePlayingMark()
        self.playingMarkIconView.isHidden = true
    }

    private func generatePlayingMark() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let image = renderer.image { ctx in
            let circle = UIBezierPath(arcCenter: CGPoint(x: 5, y: 5), radius: 2.5, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.addPath(circle.cgPath)
            ctx.cgContext.drawPath(using: .fill)
        }
        return image
    }
}
