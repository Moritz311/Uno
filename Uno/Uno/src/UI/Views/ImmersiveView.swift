//
//  ImmersiveView.swift
//  Uno
//
//  Created by Schuetz Moritz - s2310237015 on 21.11.25.
//
import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    @StateObject private var game = UnoGame()
    private let renderer = CardRenderer()

    var body: some View {
        ZStack {
            RealityView { content in
                renderInitial(in: content)
            }
            .ignoresSafeArea()

            GameHUD(
                game: game,
                onDraw: { game.send(.drawCard) },
                onPass: { game.send(.pass) },
                onCallUno: { game.send(.callUno) }
            )
        }
    }

    private func renderInitial(in content: RealityViewContent) {
        guard let idx = game.state.players.firstIndex(where: { $0.id == game.localPlayerID }) else {
            return
        }

        let hand = game.state.players[idx].hand
        renderer.renderInitialSync(cards: hand, into: content)
    }
}
