//
//  GameHUD.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import SwiftUI

/// Einfaches HUD mit Buttons und Spielinfos.
/// Enthält: Accessibility + Hover Effects + kleine Custom Animations (SwiftUI)
struct GameHUD: View {

    @ObservedObject var game: UnoGame

    var onDraw: () -> Void
    var onPass: () -> Void
    var onCallUno: () -> Void

    // MARK: - UI State (Hover + Animation)
    @State private var hoverDraw = false
    @State private var hoverPass = false
    @State private var hoverUno  = false

    @State private var pressedDraw = false
    @State private var pressedPass = false
    @State private var pressedUno  = false

    // Optional: kleiner “Pulse”-Effekt wenn sich der Nachziehstapel ändert
    @State private var drawPilePulse = false

    var body: some View {
        VStack {
            // Oben: Infos
            infoHeader
                .padding(.horizontal)
                .padding(.top, 8)

            Spacer()

            // Unten: Buttons
            controls
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.bottom, 24)
                .padding(.horizontal, 32)
                // Accessibility: gesamtes Bedienfeld ist eine Gruppe
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Spielsteuerung")
                .accessibilityHint("Enthält Aktionen zum Ziehen, Passen und UNO rufen.")
        }
    }

    // MARK: - Subviews

    private var infoHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {

                Text("Aktueller Spieler: \(currentPlayerName)")
                    .font(.headline)
                    // Accessibility
                    .accessibilityLabel("Aktueller Spieler")
                    .accessibilityValue(currentPlayerName)

                Group {
                    if let top = topDiscard {
                        Text("Ablagestapel: \(describe(card: top))")
                    } else {
                        Text("Ablagestapel: leer")
                    }
                }
                .font(.subheadline)
                // Accessibility: Ablagestapel-Info als eigener Block
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Ablagestapel")
                .accessibilityValue(topDiscard.map { describe(card: $0) } ?? "leer")

                Text("Nachziehstapel: \(game.state.drawPile.count) Karten")
                    .font(.subheadline)
                    // Kleine Custom Animation bei Änderung
                    .scaleEffect(drawPilePulse ? 1.05 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: drawPilePulse)
                    // Accessibility
                    .accessibilityLabel("Nachziehstapel")
                    .accessibilityValue("\(game.state.drawPile.count) Karten")
            }

            Spacer()
        }
        // Damit VoiceOver die Infos als Block liest
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Spielinformationen")
        .onChange(of: game.state.drawPile.count) { _, _ in
            // Kurzer “Pulse” wenn sich die Anzahl ändert
            drawPilePulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                drawPilePulse = false
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 16) {

            Button {
                tapAnimate($pressedDraw) { onDraw() }
            } label: {
                Label("Ziehen", systemImage: "arrow.down.square")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderedProminent)
            // Hover Effects (visionOS)
            .hoverEffect(.lift)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) { hoverDraw = hovering }
            }
            // Custom Animation: leichter Scale beim Hover/Press
            .scaleEffect((hoverDraw || pressedDraw) ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.12), value: hoverDraw)
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: pressedDraw)
            // Accessibility
            .accessibilityLabel("Karte ziehen")
            .accessibilityHint("Zieht eine Karte vom Nachziehstapel.")
            .accessibilityAddTraits(.isButton)

            Button {
                tapAnimate($pressedPass) { onPass() }
            } label: {
                Label("Passen", systemImage: "hand.raised")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.bordered)
            .hoverEffect(.highlight)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) { hoverPass = hovering }
            }
            .scaleEffect((hoverPass || pressedPass) ? 1.04 : 1.0)
            .animation(.easeOut(duration: 0.12), value: hoverPass)
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: pressedPass)
            // Accessibility
            .accessibilityLabel("Passen")
            .accessibilityHint("Überspringt deinen Zug, ohne eine Karte zu spielen.")
            .accessibilityAddTraits(.isButton)

            Button {
                tapAnimate($pressedUno) { onCallUno() }
            } label: {
                Label("UNO!", systemImage: "exclamationmark.bubble")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .hoverEffect(.lift)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) { hoverUno = hovering }
            }
            .scaleEffect((hoverUno || pressedUno) ? 1.06 : 1.0)
            .animation(.easeOut(duration: 0.12), value: hoverUno)
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: pressedUno)
            // Accessibility
            .accessibilityLabel("UNO rufen")
            .accessibilityHint("Rufe UNO, wenn du nur noch eine Karte hast.")
            .accessibilityAddTraits(.isButton)
        }
        // Für VoiceOver: Reihenfolge klar und “kurz”
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(1)
    }

    // MARK: - Helpers

    /// Kurzer “Press”-Effekt, SwiftUI-konform über Binding (kein `inout`!)
    private func tapAnimate(_ flag: Binding<Bool>, action: () -> Void) {
        flag.wrappedValue = true
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            flag.wrappedValue = false
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
