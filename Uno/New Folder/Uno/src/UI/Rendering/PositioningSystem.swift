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

    /// Positioniert die Handkarten des lokalen Spielers in einem leichten Halbkreis vor dem Spieler
    static func positionForHandCard(index: Int, total: Int) -> SIMD3<Float> {
        guard total > 0 else { return [0, 0, -1] }

        let spread: Float = 0.01   // Abstand zwischen Karten
        let centerOffset = Float(total - 1) / 2.0
        let x = (Float(index) - centerOffset) * spread
        let y: Float = -0.1
        let z: Float = -1.0
        return [x, y, z]
    }
}
