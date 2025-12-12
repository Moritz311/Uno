//
//  UnoGame.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import Combine

/// Bridge zwischen Engine (reine Logik) und SwiftUI / RealityKit
@MainActor
final class UnoGame: ObservableObject {

    @Published private(set) var state: UnoGameState

    private var engine: UnoEngine
    let localPlayerID: PlayerID

    init(
        playerNames: [String] = ["Spieler 1", "Spieler 2"],
        localPlayerIndex: Int = 0,
        cardsPerPlayer: Int = 7
    ) {
        let initialState = DeckFactory.createInitialState(
            playerNames: playerNames,
            cardsPerPlayer: cardsPerPlayer
        )
        self.engine = UnoEngine(state: initialState)
        self.state = initialState
        self.localPlayerID = initialState.players[localPlayerIndex].id
    }

    func send(_ action: UnoAction) {
        do {
            try engine.apply(action: action, by: localPlayerID)
            state = engine.state
        } catch {
            print("❌ Illegal move or engine error:", error)
        }
    }

    /// Wird von InteractionHandlers aufgerufen, um eine Karte „zur Hand“ zurück zu setzen.
    /// Aktuell: Nur Platzhalter, da Positionen von RealityKit gehandhabt werden.
    func returnCardToHand(id: UUID) {
        // Hier könntest du später UI-States für Kartenpositionen verwalten.
    }
}
