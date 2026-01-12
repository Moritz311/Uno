//
//  CardRendering.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import RealityKit
import _RealityKit_SwiftUI
import TabletopKit

/// Verwaltet die Darstellung der Karten im 3D-Raum
final class CardRenderer {
    
    func entity(for cardID: UUID) -> Entity? {
        handEntities[cardID]
    }

    private let mapper = UnoCardEntityMapper.shared

    /// Map: cardID → Entity
    private var handEntities: [UUID: Entity] = [:]

    /// Entfernt alle Handkarten aus dem Content
    func clear(from content: RealityViewContent) {
        for entity in handEntities.values {
            content.remove(entity)
        }
        handEntities.removeAll()
    }

    /// Initialer Render der Hand (synchron, EINZIGE Render-Methode)
    func renderInitialSync(cards: [UnoCard], into content: RealityViewContent) {
        handEntities.removeAll()

        let total = cards.count
        guard total > 0 else { return }

        for (index, card) in cards.enumerated() {
            do {
                let entity = try mapper.makeEntitySync(for: card)

                entity.position = PositioningSystem.positionForHandCard(
                    index: index,
                    total: total
                )

                // Einheitliche Neigung nach vorne
                entity.orientation = simd_quatf(
                    angle: .pi / 4,
                    axis: [1, 0, 0]
                )

                content.add(entity)
                handEntities[card.id] = entity

            } catch {
                print("Fehler beim Karten-Rendern:", error)
            }
        }
    }
    


}
