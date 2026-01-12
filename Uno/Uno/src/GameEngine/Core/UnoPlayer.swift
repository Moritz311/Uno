//
//  UnoPlayer.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation

/// Logische Spieler-ID (statt direkt UUID zu benutzen)
public struct PlayerID: Hashable, Codable {
    public let rawValue: UUID

    public init(rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }
}

/// Zustand eines Spielers
public struct UnoPlayer: Codable, Identifiable {
    public var id: PlayerID
    public var name: String
    public var hand: [UnoCard]
    public var hasAnnouncedUno: Bool

    public init(id: PlayerID = PlayerID(),
                name: String,
                hand: [UnoCard] = [],
                hasAnnouncedUno: Bool = false) {
        self.id = id
        self.name = name
        self.hand = hand
        self.hasAnnouncedUno = hasAnnouncedUno
    }
}
