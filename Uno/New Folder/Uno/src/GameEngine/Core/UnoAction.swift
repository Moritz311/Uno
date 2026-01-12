//
//  UnoAction.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation

/// Aktionen, die ein Spieler ausführen kann
public enum UnoAction: Codable {
    case playCard(cardID: UUID, chosenColor: UnoColor?)
    case drawCard
    case pass
    case callUno
}
