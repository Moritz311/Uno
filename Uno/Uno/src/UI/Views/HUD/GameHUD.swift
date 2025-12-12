//
//  GameHUD.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import SwiftUI

/// Einfaches HUD mit Buttons und Spielinfos.
struct GameHUD: View {

    @ObservedObject var game: UnoGame

    var onDraw: () -> Void
    var onPass: () -> Void
    var onCallUno: () -> Void

    var body: some View {
        VStack {
            // Oben: Infos
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aktueller Spieler: \(currentPlayerName)")
                        .font(.headline)

                    if let top = topDiscard {
                        Text("Ablagestapel: \(describe(card: top))")
                            .font(.subheadline)
                    } else {
                        Text("Ablagestapel: leer")
                            .font(.subheadline)
                    }

                    Text("Nachziehstapel: \(game.state.drawPile.count) Karten")
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()

            // Unten: Buttons
            HStack(spacing: 16) {
                Button("Ziehen") {
                    onDraw()
                }
                .buttonStyle(.borderedProminent)

                Button("Passen") {
                    onPass()
                }
                .buttonStyle(.bordered)

                Button("UNO!") {
                    onCallUno()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.bottom, 24)
            .padding(.horizontal, 32)
        }
    }

    private var currentPlayerName: String {
        let idx = game.state.currentPlayerIndex
        guard idx < game.state.players.count else { return "-" }
        return game.state.players[idx].name
    }

    private var topDiscard: UnoCard? {
        game.state.discardPile.last
    }

    private func describe(card: UnoCard) -> String {
        switch card.value {
        case .number(let n):
            return "\(card.colorText) \(n)"
        case .skip:
            return "\(card.colorText) Skip"
        case .reverse:
            return "\(card.colorText) Reverse"
        case .drawTwo:
            return "\(card.colorText) +2"
        case .wild:
            return "Wild"
        case .wildDrawFour:
            return "Wild +4"
        }
    }
}

// Kleine Helper-Extension für Text
extension UnoCard {
    var colorText: String {
        switch color {
        case .red:    return "Rot"
        case .blue:   return "Blau"
        case .green:  return "Grün"
        case .yellow: return "Gelb"
        case .wild:   return "Schwarz"
        }
    }
}
