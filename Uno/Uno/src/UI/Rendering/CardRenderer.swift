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

private var drawPileEntity: Entity?
private var drawPileCards: [UnoCard] = []

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
                entity.position = [xOffset , -0.25, -1.0]

                content.add(entity)
                handEntities[card.id] = entity

                //Make a rectangular table
            } catch {
                print("❌ Fehler beim Erstellen einer Karten-Entity:", error)
            }

        }
    }
    
    func renderInitialSync(cards: [UnoCard], into content: RealityViewContent) {
        handEntities.removeAll()

        let total = cards.count
        guard total > 0 else { return }

        // -------------------------------
        // Konfiguration
        // -------------------------------
        let baseY: Float = 0.52
        let baseZ: Float = -1.0

        let fanRadius: Float = 0.35
        let maxFanAngle: Float = .pi / 8      // ~22.5°
        let tiltAngle: Float = .pi / 4       // -45°

        let centerIndex = Float(total - 1) / 2.0

        for (index, card) in cards.enumerated() {
            do {
                let entity = try mapper.makeEntitySync(for: card)

                let i = Float(index) - centerIndex
                let t = i / max(centerIndex, 1)

                // -------------------------------
                // Position im Bogen
                // -------------------------------
                let angleY = t * maxFanAngle

                let x = sin(angleY) * fanRadius
                let z = baseZ + cos(angleY) * fanRadius * 0.15

                entity.position = [
                    x,
                    baseY,
                    z
                ]

               

                // 2) Neigung nach vorne (45°)
                let tilt = simd_quatf(
                    angle: tiltAngle,
                    axis: [1, 0, 0]
                )

                // 3) Auffächern
 /*               let fan = simd_quatf(
                    angle: angleY,
                    axis: [0, -1, 0]
                )
          
  */

                // Reihenfolge ist wichtig!
                entity.orientation =  tilt //fan * tilt

              
                content.add(entity)
                handEntities[card.id] = entity

            } catch {
                print("❌ Fehler beim Karten-Rendern:", error)
            }
        }
    }


}
