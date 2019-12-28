//
//  ShowListView.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

class ShowListView: UITableView {
    static let identifier = "showCell"

    // MARK: - Lifecycle

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }

    // MARK: - Methods

    private func loadFromNib() {
        let nib = UINib(nibName: "ShowCell", bundle: nil)
        register(nib, forCellReuseIdentifier: type(of: self).identifier)
    }
}
