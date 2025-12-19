//
//  ImmersiveView.swift
//  Uno
//

import SwiftUI
import RealityKit
import RealityKitContent
import TabletopKit

struct ImmersiveView: View {

    @StateObject private var game = UnoGame()
    private let renderer = CardRenderer()

    @State private var tabletopGame: TabletopGame?
    @State private var tabletopSetup: TabletopSetup?
    @State private var didInitialize = false

    var body: some View {
        RealityView { content, attachments in
            renderInitial(in: content)

            
            if let hudEntity = attachments.entity(for: "hud") {

                // Position relativ zum Tisch:
                // +Z = Richtung Spieler
                hudEntity.position = [0, 1.0, -1.0]

                // Leicht zum Spieler neigen
                hudEntity.orientation =
                    simd_quatf(angle: -.pi / 10, axis: [1, 0, 0])

                content.add(hudEntity)
            }

        } attachments: {

            Attachment(id: "hud") {
                GameHUD(
                    game: game,
                    onDraw: { game.send(.drawCard) },
                    onPass: { game.send(.pass) },
                    onCallUno: { game.send(.callUno) }
                )
                .frame(width: 520, height: 220)
                .glassBackgroundEffect()
            }
        }
        .ignoresSafeArea()
    }

    //Setup
    private func renderInitial(in content: RealityViewContent) {

        guard !didInitialize else { return }
        didInitialize = true

        // Tabletop
        let setup = TabletopSetup(content: content)
        let tabletop = TabletopGame(tableSetup: setup.tableSetup)
        tabletop.claimAnySeat()

        tabletopSetup = setup
        tabletopGame = tabletop

        // Handkarten
        if let idx = game.state.players.firstIndex(where: {
            $0.id == game.localPlayerID
        }) {
            let hand = game.state.players[idx].hand
            renderer.renderInitialSync(cards: hand, into: content)
        }

        // Abhebestapel
        let drawPileRenderer = DrawPileRenderer()
        drawPileRenderer.setup(
            cards: game.state.drawPile,
            into: content
        )
    }
}
