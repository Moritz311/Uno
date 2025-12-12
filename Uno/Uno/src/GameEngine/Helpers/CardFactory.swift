//
//  CardFactory.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation

/// Hilfsfunktionen zur Erstellung & Initialisierung eines UNO-Decks
public enum DeckFactory {

    /// Standard-Deck:
    /// - Farben: Rot, Blau, Grün, Gelb
    /// - Zahlenkarten: 0–9, von jeder ZWEI (inkl. 0, wie du wolltest)
    /// - Spezial: Skip, Reverse, DrawTwo (je 2 pro Farbe)
    /// - Wild: 4x Wild, 4x +4
    public static func createStandardDeck() -> [UnoCard] {
        var cards: [UnoCard] = []

        let colors: [UnoColor] = [.red, .blue, .green, .yellow]

        // Zahlenkarten
        for color in colors {
            for number in 0...9 {
                // von jeder Zahl 2 Stück (inkl. 0)
                cards.append(UnoCard(color: color, value: .number(number)))
                cards.append(UnoCard(color: color, value: .number(number)))
            }

            // Spezialkarten je 2 pro Farbe
            for _ in 0..<2 {
                cards.append(UnoCard(color: color, value: .skip))
                cards.append(UnoCard(color: color, value: .reverse))
                cards.append(UnoCard(color: color, value: .drawTwo))
            }
        }

        // Wild & +4 – 4 Stück jeweils
        for _ in 0..<4 {
            cards.append(UnoCard(color: .wild, value: .wild))
            cards.append(UnoCard(color: .wild, value: .wildDrawFour))
        }

        return cards.shuffled()
    }

    /// Erstellt einen initialen GameState mit x Spielern und Handkarten
    public static func createInitialState(
        playerNames: [String],
        cardsPerPlayer: Int = 7
    ) -> UnoGameState {

        var deck = createStandardDeck()
        var players: [UnoPlayer] = []

        for name in playerNames {
            var hand: [UnoCard] = []
            for _ in 0..<cardsPerPlayer {
                if let card = deck.popLast() {
                    hand.append(card)
                }
            }
            players.append(UnoPlayer(name: name, hand: hand))
        }

        // Erste Karte für Ablagestapel
        var discard: [UnoCard] = []
        var currentColor: UnoColor = .red

        if let first = deck.popLast() {
            discard.append(first)
            currentColor = first.color == .wild ? .red : first.color
        }

        let state = UnoGameState(
            players: players,
            currentPlayerIndex: 0,
            direction: .clockwise,
            drawPile: deck,
            discardPile: discard,
            pendingDrawType: nil,
            pendingDrawCount: 0,
            currentColor: currentColor,
            unoPendingPlayerIndex: nil,
            winnerIndex: nil
        )

        return state
    }
}
