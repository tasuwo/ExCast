//
//  ChannelOwner.swift
//  Domain
//
//  Created by Tasuku Tozawa on 2019/12/26.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

// sourcery: model
/// The podcast owner contact information.
public struct ChannelOwner: Codable, Equatable {
    /// The name the owner.
    public let name: String
    /// The email address of the owner.
    public let email: String

    // MARK: - Lifecycle

    public init(
        name: String,
        email: String
    ) {
        self.name = name
        self.email = email
    }
}

extension ChannelOwner {
    // MARK: - Lifecycle

    public init?(node: XmlNode) {
        guard let name = (node |> "itunes:owner" |> "itunes:name")?.value,
            let email = (node |> "itunes:owner" |> "itunes:email")?.value else {
            return nil
        }
        self.name = name
        self.email = email
    }
}
