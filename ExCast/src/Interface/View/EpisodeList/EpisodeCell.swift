//
//  EpisodeListCell.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Domain
import UIKit

protocol EpisodeCellDelegate: AnyObject {
    func podcastEpisodeCell(_ cell: UITableViewCell, didSelect episode: Episode)
}

class EpisodeCell: UITableViewCell {
    private static var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .hour, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    public var pubDate: Date? {
        set {
            guard let date = newValue else {
                publishDateLabel.text = ""
                return
            }
            publishDateLabel.text = type(of: self).dateFormatter.string(from: date)
        }
        get {
            guard let dateString = self.publishDateLabel.text else {
                return nil
            }
            return type(of: self).dateFormatter.date(from: dateString)
        }
    }

    public var title: String {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text ?? ""
        }
    }

    public var episodeDescription: String? {
        set {
            episodeDescriptionLabel.text = newValue
        }
        get {
            return episodeDescriptionLabel.text
        }
    }

    public var duration: Double {
        set {
            lengthLabel.text = type(of: self).durationFormatter.string(from: newValue)
        }
        get {
            // TODO:
            return 0
        }
    }

    var episode: Episode?

    weak var delegate: EpisodeCellDelegate?

    // MARK: - IBOutlets

    @IBOutlet var publishDateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var episodeDescriptionLabel: UILabel!
    @IBOutlet var lengthLabel: UILabel!
    @IBOutlet var informationButton: UIButton!
    @IBOutlet var playingMarkIconView: UIImageView!

    // MARK: - IBActions

    @IBAction func didTapInformationIcon(_: UIButton) {
        guard let episode = self.episode else { return }
        delegate?.podcastEpisodeCell(self, didSelect: episode)
    }

    // MARK: - Methods

    public func setupAppearences() {
        informationButton.setTitle(NSLocalizedString("EpisodeListView.cell.detail", comment: ""), for: .normal)
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
