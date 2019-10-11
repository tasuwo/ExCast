//
//  DataSourceQuery.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/10/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import RxDataSources
import RxRelay

enum DataSourceQuery<T: Equatable & IdentifiableType> {
    case contents([AnimatableSectionModel<String, T>])
    case progress
    case error
}
