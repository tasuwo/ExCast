//
//  NotificationSettingRepository.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

protocol NotificationSettingRepository {

    func get() -> NotificationSetting?

    func add(_ setting: NotificationSetting) throws

    func clear()
    
}
