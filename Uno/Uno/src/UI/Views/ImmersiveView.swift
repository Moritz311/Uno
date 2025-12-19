//
//  ImmersiveView.swift
//  Uno
//

import SwiftUI
import RealityKit
import RealityKitContent
import TabletopKit

struct ImmersiveView: View {

    // --------------------------------------------------
    // GAME
    // --------------------------------------------------
    @StateObject private var game = UnoGame()

    // --------------------------------------------------
    // RENDERER
    // --------------------------------------------------
    private let cardRenderer = CardRenderer()
    @State private var drawPileRenderer = DrawPileRenderer()

    // --------------------------------------------------
    // TABLETOP
    // --------------------------------------------------
    @State private var tabletopGame: TabletopGame?
    @State private var tabletopSetup: TabletopSetup?
    @State private var didInitialize = false

    // --------------------------------------------------
    // CONTENT + ANIMATION STATE
    // --------------------------------------------------
    @State private var contentRef: RealityViewContent?
    @State private var isDrawAnimating = false   // 🔑 WICHTIG

    // --------------------------------------------------
    // LOCAL HAND (OBSERVABLE)
    // --------------------------------------------------
    private var localHand: [UnoCard] {
        game.state.players
            .first(where: { $0.id == game.localPlayerID })?
            .hand ?? []
    }

    var body: some View {

        RealityView { content, attachments in

            // Content-Referenz merken
            contentRef = content

            // Initiales Setup (nur einmal)
            renderInitial(in: content)

            // HUD
            if let hudEntity = attachments.entity(for: "hud") {
                hudEntity.position = [-0.5, 0.5, -0.85]
                hudEntity.orientation =
                    simd_quatf(angle: -.pi / 10, axis: [1, 0, 0])
                content.add(hudEntity)
            }

        } attachments: {

            Attachment(id: "hud") {
                GameHUD(
                    game: game,
                    onDraw: {
                        // 🔹 1) Animation blockiert Hand-Update
                        isDrawAnimating = true

                        // 🔹 2) Logik sofort ausführen
                        game.send(.drawCard)

                        // 🔹 3) Visuelle Animation starten
                        playDrawAnimation()
                    },
                    onPass: { game.send(.pass) },
                    onCallUno: { game.send(.callUno) }
                )
                .frame(width: 520, height: 220)
                .glassBackgroundEffect()
            }
        }
        .ignoresSafeArea()

        // --------------------------------------------------
        // 🔁 HAND NUR BEI STATE-ÄNDERUNG,
        //    ABER NICHT WÄHREND DRAW-ANIMATION
        // --------------------------------------------------
        .onChange(of: localHand) { _ in
            guard !isDrawAnimating else { return }
            updateHandRendering()
        }
    }

    // MARK: - INITIAL SETUP (EINMAL!)

    private func renderInitial(in content: RealityViewContent) {

        guard !didInitialize else { return }
        didInitialize = true

        // -------------------------------
        // TABLETOP
        // -------------------------------
        let setup = TabletopSetup(content: content)
        let tabletop = TabletopGame(tableSetup: setup.tableSetup)
        tabletop.claimAnySeat()

        tabletopSetup = setup
        tabletopGame = tabletop

        // -------------------------------
        // INITIAL HAND
        // -------------------------------
        updateHandRendering()

        // -------------------------------
        // DRAW PILE
        // -------------------------------
        drawPileRenderer.setup(
            cards: game.state.drawPile,
            into: content
        )
    }

    // MARK: - HAND RENDERING (STATE → VIEW)

    private func updateHandRendering() {
        guard
            let content = contentRef,
            let idx = game.state.players.firstIndex(
                where: { $0.id == game.localPlayerID }
            )
        else { return }

        cardRenderer.clear(from: content)
        cardRenderer.renderInitialSync(
            cards: game.state.players[idx].hand,
            into: content
        )
    }

    // MARK: - DRAW ANIMATION (NUR VISUELL)

    private func playDrawAnimation() {
        guard let content = contentRef else { return }

        drawPileRenderer.drawCard(into: content) { _ in
            // 🔹 Animation fertig → jetzt darf die Hand neu gerendert werden
            isDrawAnimating = false
            updateHandRendering()
        }
    }
}
