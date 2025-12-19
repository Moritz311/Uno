//
//  PositioningSystem.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//



import Foundation
import simd

/// Zuständig dafür, Karten im Raum anzuordnen
struct PositioningSystem {

    /// Positioniert die Handkarten des lokalen Spielers
    /// Linear von links nach rechts, leicht nach hinten gestaffelt
    static func positionForHandCard(index: Int, total: Int) -> SIMD3<Float> {
        guard total > 0 else { return [0, 0, -1] }

        // -------------------------------
        // Konfiguration
        // -------------------------------
        let spacingX: Float = 0.08     // Abstand links ↔ rechts
        let spacingZ: Float = 0.015    // minimaler Tiefenversatz

        let baseY: Float = 0.52
        let baseZ: Float = -1.0

        let centerOffset = Float(total - 1) / 2.0

        let x = (Float(index) - centerOffset) * spacingX
        let y = baseY
        let z = baseZ - Float(index) * spacingZ

        return [x, y, z]
    }
}
