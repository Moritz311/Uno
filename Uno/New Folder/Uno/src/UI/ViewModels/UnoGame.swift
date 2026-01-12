//
//  UnoGame.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//
import TabletopKit
import RealityKit
import SwiftUI

@Observable
@MainActor
final class UnoGame {

    let tabletopGame: TabletopGame
    let setup: GameSetup
    let renderer: GameRenderer
    let observer: GameObserver

    init() async {
        // Renderer
        renderer = GameRenderer()

        // Tisch + Deck + Ablage
        setup = GameSetup(root: renderer.root)

        // TabletopGame
        tabletopGame = TabletopGame(tableSetup: setup.setup)

        // Observer
        observer = GameObserver()
        tabletopGame.addObserver(observer)

        // Renderer anbinden
        tabletopGame.addRenderDelegate(renderer)
        renderer.game = self   // <- Typ ggf. anpassen

        // EXTREM WICHTIG
        tabletopGame.claimAnySeat()

        resetGame()
    }

    deinit {
        tabletopGame.removeObserver(observer)
        tabletopGame.removeRenderDelegate(renderer)
    }

    func resetGame() {
        let shuffled = setup.cards.shuffled()
        for card in shuffled {
            tabletopGame.addAction(
                .updateEquipment(card, faceUp: false, seatControl: .any)
            )
            tabletopGame.addAction(
                .moveEquipment(matching: card.id,
                               childOf: setup.cardStockGroup.id)
            )
        }
    }
}
