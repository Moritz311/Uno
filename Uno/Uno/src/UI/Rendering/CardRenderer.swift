//
//  CardRendering.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import RealityKit
import _RealityKit_SwiftUI

/// Verwaltet die Darstellung der Karten im 3D-Raum
final class CardRenderer {

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

    /// Initialer Render der Hand (wird beim Start einmal aufgerufen)
    func renderInitial(cards: [UnoCard], into content: RealityViewContent) async {
        // Entferne vorherige Hand
        handEntities.removeAll()

        for (index, card) in cards.enumerated() {

            do {
                let entity = try mapper.makeEntitySync(for: card)

                // Karte nebeneinander positionieren
                let xOffset = Float(index) * 0.14 - 0.45
                entity.position = [xOffset, -0.25, -1.0]

                content.add(entity)
                handEntities[card.id] = entity

            } catch {
                print("❌ Fehler beim Erstellen einer Karten-Entity:", error)
            }

        }
    }
    
    func renderInitialSync(cards: [UnoCard], into content: RealityViewContent) {
        handEntities.removeAll()

        for (index, card) in cards.enumerated() {
            do {
                // Entity synchron holen (keine async-Version)
                let entity = try mapper.makeEntitySync(for: card)

                let xOffset = Float(index) * 0.14 - 0.45
                entity.position = [xOffset, -0.25, -1.0]

                content.add(entity)
                handEntities[card.id] = entity

            } catch {
                print("❌ Fehler beim Karten-Rendern:", error)
            }
        }
    }

}
