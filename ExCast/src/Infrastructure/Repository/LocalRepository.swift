//
//  UserDefaultsRepository.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/07/20.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import Foundation

protocol LocalRespository {
    func fetch<T: Codable>(forKey name: String) -> T?
    func store<T: Codable>(obj: T, forKey name: String)
    func delete(forKey name: String) -> Void
}

public class LocalRepositoryImpl: LocalRespository {
    private let defaults: UserDefaults!

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func fetch<T>(forKey name: String) -> T? where T : Decodable, T : Encodable {
        guard let json = self.defaults.object(forKey: name) as? Data else {
            return nil
        }
        do {
            let obj = try JSONDecoder().decode(T.self, from: json)
            return obj
        } catch {
            self.delete(forKey: name)
            return nil
        }
    }
    
    public func store<T: Codable>(obj: T, forKey name: String) {
        do {
            let json = try JSONEncoder().encode(obj)
            self.defaults.set(json, forKey: name)
        } catch {
            // NOP
        }
    }
    
    public func delete(forKey name: String) {
        self.defaults.removeObject(forKey: name)
    }
}
