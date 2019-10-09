//
//  BehaviorRelay+ValueAt.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/09/29.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources
import RxRelay

extension BehaviorRelay where Element: RangeReplaceableCollection, Element.Element: AnimatableSectionModelType, Element.Index == Int {
    func value(at indexPath: IndexPath) -> Element.Element.Item {
        return value[indexPath.section].items[indexPath.item]
    }
}
