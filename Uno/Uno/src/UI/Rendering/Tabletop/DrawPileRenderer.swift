//
//  DrawPileRenderer.swift
//  Uno
//
//  Created by Fabian Neubacher on 18.12.25.
//


import RealityKit
import _RealityKit_SwiftUI

final class DrawPileRenderer {

    private let mapper = UnoCardEntityMapper.shared
    private(set) var remainingCards: [UnoCard] = []
    private(set) var pileEntity: Entity?

    func setup(
        cards: [UnoCard],
        into content: RealityViewContent
    ) {
        remainingCards = cards
        guard let topCard = cards.first else { return }

        do {
            let entity = try mapper.makeEntitySync(for: topCard)

            entity.position = SIMD3<Float>(0.45, 0.52, -1.0)

            entity.orientation = simd_quatf(
                angle: .pi,
                axis: [-1, 0, 0]
            )

            // 👇 nötig, damit SwiftUI Tap funktioniert
            entity.components.set(InputTargetComponent())

            content.add(entity)
            pileEntity = entity

        } catch {
            print("❌ Fehler beim Setup des Abhebestapels:", error)
        }
    }

    func drawCard(
        into content: RealityViewContent,
        completion: @escaping (UnoCard) -> Void
    ) {
        guard
            let entity = pileEntity,
            !remainingCards.isEmpty
        else { return }

        let drawnCard = remainingCards.removeFirst()

        let start = entity.position
        let target = SIMD3<Float>(0, 0.52, -1.0)

        let duration: Float = 0.35
        var elapsed: Float = 0
        var finished = false

        content.subscribe(to: SceneEvents.Update.self) { event in
            guard !finished else { return }

            elapsed += Float(event.deltaTime)
            let t = min(elapsed / duration, 1)

            entity.position = start + (target - start) * t

            if t >= 1 {
                finished = true
                entity.removeFromParent()
                self.pileEntity = nil
                completion(drawnCard)
            }
        }
    }
}
