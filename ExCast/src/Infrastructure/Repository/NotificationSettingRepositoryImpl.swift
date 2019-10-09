//
//  NotificationSettingRepository.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/11.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

class NotificationSettingRepositoryImpl /* : NotificationSettingRepository */ {
    private let repository: LocalRespository

    private static let key = "Notification"

    init(repository: LocalRespository) {
        self.repository = repository
    }

    func get() -> NotificationSetting? {
        return repository.fetch(forKey: NotificationSettingRepositoryImpl.key)
    }

    func add(_ setting: NotificationSetting) {
        repository.store(obj: setting, forKey: NotificationSettingRepositoryImpl.key)
    }

    func clear() {
        repository.delete(forKey: NotificationSettingRepositoryImpl.key)
    }
}
