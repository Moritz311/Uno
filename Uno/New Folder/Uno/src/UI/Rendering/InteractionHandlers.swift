//
//  InteractionHandler.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import RealityKit

/// Verwaltet Logik für Interaktionen mit Karten.
/// Aktuell ohne direkte Verbindung zu RealityKit-Callbacks – diese kannst du später nachrüsten.
final class InteractionHandlers {

    private let game: UnoGame

    init(game: UnoGame) {
        self.game = game
    }

    /// Karte wurde (z.B. per Tap) gespielt
    func playCard(with entity: Entity) {
        guard let cardID = UUID(uuidString: entity.name) else { return }
        game.send(.playCard(cardID: cardID, chosenColor: nil))
    }

    /// Karte soll wieder zur Hand zurück
    func returnCard(with entity: Entity) {
        guard let cardID = UUID(uuidString: entity.name) else { return }
        game.returnCardToHand(id: cardID)
    }

    /// UNO-Button gedrückt
    func callUno() {
        game.send(.callUno)
    }

    /// Karte ziehen (z.B. via Button / Zone)
    func drawCard() {
        game.send(.drawCard)
    }

    /// Zug passen (z.B. nach Ziehen)
    func passTurn() {
        game.send(.pass)
    }
}
