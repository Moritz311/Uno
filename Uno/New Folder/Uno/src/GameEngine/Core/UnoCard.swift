//
//  UnoCard.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation

/// Eine einzelne UNO-Karte
public struct UnoCard: Identifiable, Codable, Hashable {

    public let id: UUID
    public let color: UnoColor
    public let value: UnoValue

    public init(id: UUID = UUID(), color: UnoColor, value: UnoValue) {
        self.id = id
        self.color = color
        self.value = value
    }

    public static func == (lhs: UnoCard, rhs: UnoCard) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
