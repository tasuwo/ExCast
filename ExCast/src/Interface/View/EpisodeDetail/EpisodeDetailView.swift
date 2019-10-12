//
//  EpisodeDetailView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/02.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit
import WebKit

public class EpisodeDetailView: UIView {
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

    public var thumbnail: UIImage? {
        set {
            episodeThumbnailView.image = newValue
        }
        get {
            return episodeThumbnailView.image
        }
    }

    public var publishDate: Date? {
        set {
            guard let date = newValue else {
                episodePubDateLabel.text = ""
                return
            }
            episodePubDateLabel.text = type(of: self).dateFormatter.string(from: date)
        }
        get {
            guard let dateString = self.episodePubDateLabel.text else {
                return nil
            }
            return type(of: self).dateFormatter.date(from: dateString)
        }
    }

    public var title: String {
        set {
            episodeTitleLabel.text = newValue
        }
        get {
            return episodeTitleLabel.text ?? ""
        }
    }

    public var duration: Double {
        set {
            episodeDurationLabel.text = type(of: self).durationFormatter.string(from: newValue)
        }
        get {
            // TODO:
            return 0
        }
    }

    public var episodeDescription: String {
        set {
            let fontSize = episodeDescriptionLabel.font!.pointSize
            let color: String = {
                if #available(iOS 13.0, *) {
                    return UIColor.label.rgbString
                } else {
                    return UIColor.black.rgbString
                }
            }()
            let htmlString = String(format: "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize); color: \(color)\">%@</span>", newValue)
            guard let data = htmlString.data(using: .utf8) else {
                return
            }

            DispatchQueue.main.async {
                let text = try? NSAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue,
                    ],
                    documentAttributes: nil
                )
                self.episodeDescriptionLabel.attributedText = text
            }
        }
        get {
            return episodeDescriptionLabel.attributedText.string
        }
    }

    // MARK: - IBOutlets

    @IBOutlet var baseView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var episodeThumbnailView: UIImageView!
    @IBOutlet var episodePubDateLabel: UILabel!
    @IBOutlet var episodeTitleLabel: UILabel!
    @IBOutlet var episodeDurationLabel: UILabel!
    @IBOutlet var episodeDescriptionLabel: UITextView!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setupAppearences()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
        setupAppearences()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let bundle = Bundle.main

        bundle.loadNibNamed("EpisodeDetailView", owner: self, options: nil)

        // TODO: ここのサイズ調整がうまくいかないので、どうにかする。。。
        baseView.frame = UIScreen.main.bounds
        addSubview(baseView)
    }

    private func setupAppearences() {
        baseView.isScrollEnabled = true
        episodeThumbnailView.layer.cornerRadius = 10
        episodeDescriptionLabel.isEditable = false
        episodeDescriptionLabel.isSelectable = true
        episodeDescriptionLabel.isScrollEnabled = false
    }
}
