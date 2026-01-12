//
//  UnoEngine.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation

public enum UnoEngineError: Error {
    case notPlayersTurn
    case illegalMove
    case cardNotInHand
    case mustResolvePendingDrawFirst
    case invalidChosenColor
}

/// Kern der Spiel-Logik; mutiert den GameState
public struct UnoEngine {

    public private(set) var state: UnoGameState

    public init(state: UnoGameState) {
        self.state = state
    }

    // MARK: - Public API

    public mutating func apply(action: UnoAction, by playerID: PlayerID) throws {

        // 0) UNO-Strafe prüfen (wenn ein anderer Spieler versucht zu spielen und einer hängt auf 1 Karte ohne UNO)
        applyUnoPenaltyIfNeeded(triggeredBy: playerID)

        guard !state.isGameOver else { return }

        let currentIndex = state.currentPlayerIndex
        guard state.players[currentIndex].id == playerID else {
            throw UnoEngineError.notPlayersTurn
        }

        switch action {
        case let .playCard(cardID, chosenColor):
            try handlePlayCard(cardID: cardID, chosenColor: chosenColor)

        case .drawCard:
            try handleDrawCard()

        case .pass:
            try handlePass()

        case .callUno:
            handleCallUno()
        }

        // Gewinner prüfen
        checkWinCondition()
    }

    // MARK: - Actions

    private mutating func handlePlayCard(cardID: UUID, chosenColor: UnoColor?) throws {
        let currentIndex = state.currentPlayerIndex
        var player = state.players[currentIndex]

        guard let cardIdx = player.hand.firstIndex(where: { $0.id == cardID }) else {
            throw UnoEngineError.cardNotInHand
        }

        let card = player.hand[cardIdx]

        // Wenn gerade eine Draw-Kette läuft, darf nur dieselbe Art (+2 / +4) gelegt werden
        if let pending = state.pendingDrawType {
            switch pending {
            case .drawTwo:
                guard card.value == .drawTwo else {
                    throw UnoEngineError.mustResolvePendingDrawFirst
                }
            case .drawFour:
                guard card.value == .wildDrawFour else {
                    throw UnoEngineError.mustResolvePendingDrawFirst
                }
            }
        } else {
            // Normale Legeregel prüfen
            guard canPlay(card: card) else {
                throw UnoEngineError.illegalMove
            }
        }

        // Karte aus Hand entfernen
        player.hand.remove(at: cardIdx)
        state.players[currentIndex] = player

        // Karte auf Ablagestapel legen
        state.discardPile.append(card)

        // Farbe aktualisieren
        switch card.value {
        case .wild, .wildDrawFour:
            // Spieler MUSS eine neue Farbe wählen
            guard let color = chosenColor, !color.isWild else {
                throw UnoEngineError.invalidChosenColor
            }
            state.currentColor = color
        default:
            state.currentColor = card.color
        }

        // Effekte der Karte anwenden
        applyCardEffect(card, currentPlayerIndex: currentIndex)

        // UNO-Status setzen, falls Spieler jetzt 1 Karte hat
        if state.players[currentIndex].hand.count == 1 {
            state.unoPendingPlayerIndex = currentIndex
            state.players[currentIndex].hasAnnouncedUno = false
        } else if state.players[currentIndex].hand.count == 0 {
            // Gewinnfall wird später in checkWinCondition behandelt
        } else {
            // Mehr als 1 Karte: UNO-Pending für diesen Spieler zurücksetzen
            if state.unoPendingPlayerIndex == currentIndex {
                state.unoPendingPlayerIndex = nil
            }
        }
    }

    private mutating func handleDrawCard() throws {
        // Wenn eine Draw-Kette läuft → alle fälligen Karten ziehen, dann Zug weiter
        let currentIndex = state.currentPlayerIndex

        if let pending = state.pendingDrawType, state.pendingDrawCount > 0 {
            drawCards(for: currentIndex, count: state.pendingDrawCount)
            state.pendingDrawType = nil
            state.pendingDrawCount = 0
            advanceTurn()
            return
        }

        // Normale Ziehkarte (eine Karte)
        drawCards(for: currentIndex, count: 1)
        // Danach darf der Spieler theoretisch noch passen oder ggf. spielen;
        // diese Logik lässt "pass" explizit zu.
    }

    private mutating func handlePass() throws {
        // In einer echten UNO-Variante würdest du prüfen, ob der Spieler gezogen hat o.ä.
        // Hier: Zug einfach weitergeben
        advanceTurn()
    }

    private mutating func handleCallUno() {
        let idx = state.currentPlayerIndex
        // Nur sinnvoll, wenn Spieler genau eine Karte hat
        if state.players[idx].hand.count == 1 {
            state.players[idx].hasAnnouncedUno = true
            if state.unoPendingPlayerIndex == idx {
                state.unoPendingPlayerIndex = nil
            }
        }
    }

    // MARK: - Helper: Effekte, Win, Draw, Turn

    private func canPlay(card: UnoCard) -> Bool {
        guard let top = state.discardPile.last else {
            // erste Karte im Spiel – sollte über Setup geregelt sein
            return true
        }

        // Wild & +4 gehen immer (Hausregel: vereinfacht)
        switch card.value {
        case .wild, .wildDrawFour:
            return true
        default:
            break
        }

        // Farbe passt?
        if card.color == state.currentColor {
            return true
        }

        // Wert passt?
        if card.value == top.value {
            return true
        }

        return false
    }

    private mutating func applyCardEffect(_ card: UnoCard, currentPlayerIndex: Int) {
        switch card.value {
        case .skip:
            advanceTurn(skipping: 1)

        case .reverse:
            if state.players.count == 2 {
                // Bei 2 Spielern ist Reverse wie Skip
                advanceTurn(skipping: 1)
            } else {
                state.direction.toggle()
                advanceTurn()
            }

        case .drawTwo:
            // Neue Draw-Kette oder fortsetzen
            if let pending = state.pendingDrawType, pending == .drawTwo {
                state.pendingDrawCount += 2
            } else {
                state.pendingDrawType = .drawTwo
                state.pendingDrawCount = 2
            }
            advanceTurn()

        case .wildDrawFour:
            if let pending = state.pendingDrawType, pending == .drawFour {
                state.pendingDrawCount += 4
            } else {
                state.pendingDrawType = .drawFour
                state.pendingDrawCount = 4
            }
            advanceTurn()

        case .number, .wild:
            advanceTurn()
        }
    }

    private mutating func drawCards(for playerIndex: Int, count: Int) {
        guard count > 0 else { return }

        for _ in 0..<count {
            if state.drawPile.isEmpty {
                // Ablagestapel (ohne oberste Karte) mischen und nachziehen
                if state.discardPile.count > 1 {
                    var newDraw = state.discardPile.dropLast()
                    newDraw.shuffle()
                    state.drawPile = Array(newDraw)
                    state.discardPile = [state.discardPile.last!]
                } else {
                    // Keine Karten mehr
                    return
                }
            }

            if let card = state.drawPile.popLast() {
                state.players[playerIndex].hand.append(card)
            }
        }
    }

    private mutating func advanceTurn(skipping: Int = 0) {
        let count = state.players.count
        guard count > 0 else { return }

        var steps = 1 + skipping
        if state.direction == .counterClockwise {
            steps *= -1
        }

        let newIndex = (state.currentPlayerIndex + steps % count + count) % count
        state.currentPlayerIndex = newIndex
    }

    private mutating func checkWinCondition() {
        for (idx, player) in state.players.enumerated() {
            if player.hand.isEmpty {
                state.winnerIndex = idx
                break
            }
        }
    }

    /// Wendet eine UNO-Strafe an, falls jemand nicht UNO gesagt hat,
    /// und ein anderer Spieler gerade eine Aktion ausführt.
    private mutating func applyUnoPenaltyIfNeeded(triggeredBy: PlayerID) {
        guard let idx = state.unoPendingPlayerIndex,
              idx < state.players.count else { return }

        // Nur bestrafen, wenn jemand anderes als der betroffene Spieler jetzt handelt
        if state.players[idx].id != triggeredBy &&
            state.players[idx].hand.count == 1 &&
            state.players[idx].hasAnnouncedUno == false {

            drawCards(for: idx, count: 2)
        }

        state.unoPendingPlayerIndex = nil
    }
}
