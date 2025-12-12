//
//  UnoGameState.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation

public enum TurnDirection: Int, Codable {
    case clockwise = 1
    case counterClockwise = -1

    mutating public func toggle() {
        self = (self == .clockwise) ? .counterClockwise : .clockwise
    }
}

public enum PendingDrawType: Codable {
    case drawTwo
    case drawFour
}

/// Gesamter Zustand eines UNO-Spiels
public struct UnoGameState: Codable {

    public var players: [UnoPlayer]
    public var currentPlayerIndex: Int
    public var direction: TurnDirection

    public var drawPile: [UnoCard]
    public var discardPile: [UnoCard]

    /// Falls gerade eine +2/+4-Kette läuft
    public var pendingDrawType: PendingDrawType?
    public var pendingDrawCount: Int

    /// Aktuelle Farbe auf dem Ablagestapel (wichtig nach Wild / +4)
    public var currentColor: UnoColor

    /// Index eines Spielers, der auf 1 Karte ist, aber evtl. UNO nicht gerufen hat
    public var unoPendingPlayerIndex: Int?

    /// Gewinner-Index (falls das Spiel vorbei ist)
    public var winnerIndex: Int?

    public init(players: [UnoPlayer],
                currentPlayerIndex: Int,
                direction: TurnDirection,
                drawPile: [UnoCard],
                discardPile: [UnoCard],
                pendingDrawType: PendingDrawType? = nil,
                pendingDrawCount: Int = 0,
                currentColor: UnoColor,
                unoPendingPlayerIndex: Int? = nil,
                winnerIndex: Int? = nil) {

        self.players = players
        self.currentPlayerIndex = currentPlayerIndex
        self.direction = direction
        self.drawPile = drawPile
        self.discardPile = discardPile
        self.pendingDrawType = pendingDrawType
        self.pendingDrawCount = pendingDrawCount
        self.currentColor = currentColor
        self.unoPendingPlayerIndex = unoPendingPlayerIndex
        self.winnerIndex = winnerIndex
    }

    public var isGameOver: Bool {
        winnerIndex != nil
    }

    public var currentPlayer: UnoPlayer {
        players[currentPlayerIndex]
    }
}
