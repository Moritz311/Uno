//
//  ImmersiveView.swift
//  Uno
//

import SwiftUI
import RealityKit
import RealityKitContent
import TabletopKit

struct ImmersiveView: View {

     
    // GAME
    @StateObject private var game = UnoGame()

     
    // RENDERER
    private let cardRenderer = CardRenderer()
    @State private var drawPileRenderer = DrawPileRenderer()
    @State private var discardPileRenderer = DiscardPileRenderer()

     
    // TABLETOP
    @State private var tabletopGame: TabletopGame?
    @State private var tabletopSetup: TabletopSetup?
    @State private var didInitialize = false

     
    // CONTENT + ANIMATION STATE
    @State private var contentRef: RealityViewContent?
    @State private var isDrawAnimating = false

     
    // DROP DETECTION
    @State private var dropSubscription: EventSubscription?

    // pro Karte: letzte Position + wie lange stabil in Zone
    @State private var lastWorldPos: [UUID: SIMD3<Float>] = [:]
    @State private var stableTimeInZone: [UUID: TimeInterval] = [:]
    @State private var alreadyTriggered: Set<UUID> = []

    @State private var lastDiscardVisualizedID: UUID?

     
    // LOCAL HAND (OBSERVABLE)
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
                hudEntity.orientation = simd_quatf(angle: -.pi / 10, axis: [1, 0, 0])
                content.add(hudEntity)
            }

        } attachments: {

            Attachment(id: "hud") {
                GameHUD(
                    game: game,
                    onDraw: {
                        isDrawAnimating = true
                        game.send(.drawCard)
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

        // Hand-Update wie bisher
        .onChange(of: localHand) { _ in
            guard !isDrawAnimating else { return }
            updateHandRendering()
            cleanupDropTracking()
        }

        .onChange(of: game.state.discardPile) { pile in
            guard let top = pile.last, let content = contentRef else { return }

            if lastDiscardVisualizedID == top.id {
                // wir haben diese Karte bereits visuell via Snap platziert
                return
            }

            discardPileRenderer.push(card: top, into: content)
            lastDiscardVisualizedID = top.id
        }
    }

    // MARK: - INITIAL SETUP (EINMAL!)

    private func renderInitial(in content: RealityViewContent) {

        guard !didInitialize else { return }
        didInitialize = true

         // TABLETOP
         let setup = TabletopSetup(content: content)
        let tabletop = TabletopGame(tableSetup: setup.tableSetup)
        tabletop.claimAnySeat()

        tabletopSetup = setup
        tabletopGame = tabletop

         // INITIAL HAND
         updateHandRendering()

         // DRAW PILE
         drawPileRenderer.setup(
            cards: game.state.drawPile,
            into: content
        )

         // DISCARD PILE (Marker + Stapel)
         discardPileRenderer.setup(
            into: content,
            center: SIMD3<Float>(0.28, 0.52, -1.35),
            size: SIMD2<Float>(0.18, 0.24)
        )

         // DROP-DETECTION starten
         setupDropDetection(in: content)
    }

    // MARK: - HAND RENDERING (STATE → VIEW)

    private func updateHandRendering() {
        guard
            let content = contentRef,
            let idx = game.state.players.firstIndex(where: { $0.id == game.localPlayerID })
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
            isDrawAnimating = false
            updateHandRendering()
        }
    }

    // MARK: - DROP DETECTION (Drag in Zone => auto play)

    private func setupDropDetection(in content: RealityViewContent) {
        guard dropSubscription == nil else { return }

        dropSubscription = content.subscribe(to: SceneEvents.Update.self) { event in
            if isDrawAnimating { return }

            let dt = event.deltaTime
            let eps: Float = 0.0015
            let requiredStable: TimeInterval = 0.20

            for card in localHand {
                let id = card.id
                if alreadyTriggered.contains(id) { continue }

                guard let entity = cardRenderer.entity(for: id) else { continue }

                let p = entity.position(relativeTo: nil)

                if discardPileRenderer.contains(worldPosition: p) {

                    let last = lastWorldPos[id] ?? p
                    let moved = simd_length(p - last)

                    if moved < eps {
                        stableTimeInZone[id, default: 0] += dt
                    } else {
                        stableTimeInZone[id] = 0
                    }

                    lastWorldPos[id] = p

                    if stableTimeInZone[id, default: 0] >= requiredStable {
                        alreadyTriggered.insert(id)

                       
                        discardPileRenderer.snapEntityToPile(entity)

                        lastDiscardVisualizedID = id

                        Task { @MainActor in
                            game.send(.playCard(cardID: id, chosenColor: nil))
                        }
                    }
                } else {
                    stableTimeInZone[id] = 0
                    lastWorldPos[id] = p
                }
            }
        }
    }

    private func cleanupDropTracking() {
        let ids = Set(localHand.map { $0.id })

        stableTimeInZone.keys.filter { !ids.contains($0) }.forEach { stableTimeInZone.removeValue(forKey: $0) }
        lastWorldPos.keys.filter { !ids.contains($0) }.forEach { lastWorldPos.removeValue(forKey: $0) }
        alreadyTriggered = alreadyTriggered.intersection(ids)
    }
}
