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

    // Karten, die noch nicht gerendert wurden
    private(set) var remainingCards: [UnoCard] = []

    // Sichtbare Karten (max. 5)
    private var visibleEntities: [Entity] = []

    // Root-Entity des Stapels
    private let root = Entity()

    private let maxVisible = 5
    private let yStep: Float = 0.0012

    private var drawSubscription: EventSubscription?

    // MARK: - Setup

    func setup(
        cards: [UnoCard],
        into content: RealityViewContent
    ) {
        remainingCards = cards
        visibleEntities.removeAll()
        root.children.removeAll()

        root.position = SIMD3<Float>(0.0, 0.52, -1.2)
        root.orientation = simd_quatf(angle: .pi, axis: [-1, 0, 0])

        let initialCount = min(maxVisible, remainingCards.count)
        for index in 0..<initialCount {
            let card = remainingCards.removeFirst()
            let entity = makeCardEntity(card, slot: index)
            root.addChild(entity)
            visibleEntities.append(entity)
        }

        updateInteractivity()
        content.add(root)
    }

    // MARK: - Draw Card

    func drawCard(
        into content: RealityViewContent,
        completion: @escaping (UnoCard) -> Void
    ) {
        guard
            let topEntity = visibleEntities.first,
            let cardComponent = topEntity.components[UnoCardComponent.self]
        else { return }

        let drawnCard = cardComponent.card

        let start = topEntity.position
        let target = start + SIMD3<Float>(-0.25, 0, 0)

        let duration: Float = 0.35
        var elapsed: Float = 0

        drawSubscription?.cancel()
        drawSubscription = content.subscribe(to: SceneEvents.Update.self) { event in
            elapsed += Float(event.deltaTime)
            let t = min(elapsed / duration, 1)

            topEntity.position = start + (target - start) * t

            if t >= 1 {
                self.drawSubscription?.cancel()
                topEntity.removeFromParent()
                self.visibleEntities.removeFirst()

                completion(drawnCard)

                // 🔴 Stapel komplett leer → entfernen
                if self.visibleEntities.isEmpty && self.remainingCards.isEmpty {
                    self.removeDrawPile()
                    return
                }

                self.shiftAndRefill(in: content)
            }
        }
    }

    // MARK: - Shift / Refill

    private func shiftAndRefill(in content: RealityViewContent) {

        let canRefill = !remainingCards.isEmpty

        // 🔑 Nur rutschen, wenn unten auch wirklich eine neue Karte nachkommt
        if canRefill {
            for (index, entity) in visibleEntities.enumerated() {
                animateMove(
                    entity,
                    to: slotPosition(index),
                    in: content
                )
            }
        }

        // Neue Karte unten einsetzen
        if canRefill && visibleEntities.count < maxVisible {
            let card = remainingCards.removeFirst()
            let newEntity = makeCardEntity(card, slot: visibleEntities.count)
            root.addChild(newEntity)
            visibleEntities.append(newEntity)
        }

        updateInteractivity()
    }

    // MARK: - Helpers

    private func removeDrawPile() {
        root.removeFromParent()
        visibleEntities.removeAll()
    }

    private func makeCardEntity(_ card: UnoCard, slot: Int) -> Entity {
        let entity = try! mapper.makeEntitySync(for: card)
        entity.position = slotPosition(slot)
        entity.components.set(UnoCardComponent(card: card))
        return entity
    }

    private func slotPosition(_ index: Int) -> SIMD3<Float> {
        SIMD3<Float>(0, Float(index) * yStep, 0)
    }

    private func updateInteractivity() {
        guard !visibleEntities.isEmpty else { return }

        for (index, entity) in visibleEntities.enumerated() {
            if index == 0 {
                entity.components.set(InputTargetComponent())
            } else {
                entity.components.remove(InputTargetComponent.self)
            }
        }
    }

    // MARK: - Animation (RealityView-konform)

    private func animateMove(
        _ entity: Entity,
        to target: SIMD3<Float>,
        in content: RealityViewContent
    ) {
        let start = entity.position
        let duration: Float = 0.2
        var elapsed: Float = 0

        var sub: EventSubscription?
        sub = content.subscribe(to: SceneEvents.Update.self) { event in
            elapsed += Float(event.deltaTime)
            let t = min(elapsed / duration, 1)

            entity.position = start + (target - start) * t

            if t >= 1 {
                sub?.cancel()
            }
        }
    }
}
