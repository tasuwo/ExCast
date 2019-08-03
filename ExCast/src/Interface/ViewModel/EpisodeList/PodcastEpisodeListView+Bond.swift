//
//  PodcastEpisodeListView+Bond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

private var handle: UInt8 = 0;

extension PodcastEpisodeListView {
    var playingMarkBond: Bond<Podcast.Episode?> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! Bond<Podcast.Episode?>
        } else {
            let bond = Bond<Podcast.Episode?>() { [unowned self] episode in
                self.playingEpisode = episode
                DispatchQueue.main.async {
                    self.reloadData()
                }
            }
            objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bond
        }
    }
}

extension PodcastEpisodeListView: Bondable {
    var designatedBond: Bond<Podcast.Episode?> {
        return self.playingMarkBond
    }
}

