//
//  DiscardPileRenderer.swift
//  Uno
//
//  Created by Fabian Neubacher on 12.01.26.
//


import RealityKit
import _RealityKit_SwiftUI

final class DiscardPileRenderer {

    private let mapper = UnoCardEntityMapper.shared

    private let pileRoot = Entity()
    private var pileEntities: [Entity] = []

    private var markerEntity: Entity?

    private var zoneCenterWorld: SIMD3<Float> = [0, 0, 0]
    private var zoneHalfExtents: SIMD2<Float> = [0.09, 0.12]

    func setup(
        into content: RealityViewContent,
        center: SIMD3<Float>,
        size: SIMD2<Float> = [0.18, 0.24]
    ) {
        zoneCenterWorld = center
        zoneHalfExtents = [size.x * 0.5, size.y * 0.5]

        pileRoot.name = "discard_pile_root"
        pileRoot.position = center
        content.add(pileRoot)

        markerEntity?.removeFromParent()
        markerEntity = nil

        do {
            let random = randomCard()
            let marker = try mapper.makeEntitySync(for: random)
            marker.name = "discard_marker_card"

            marker.position = center
            marker.position.y -= 0.004
            marker.position.z += 0.0001

            marker.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])

            marker.components.set(CollisionComponent(
                shapes: [.generateBox(size: [size.x, 0.002, size.y])],
                mode: .trigger
            ))

            content.add(marker)
            markerEntity = marker

        } catch {
            print("DiscardPileRenderer.setup marker error:", error)
        }
    }

    func contains(worldPosition: SIMD3<Float>) -> Bool {
        let dx = abs(worldPosition.x - zoneCenterWorld.x)
        let dz = abs(worldPosition.z - zoneCenterWorld.z)
        return dx <= zoneHalfExtents.x && dz <= zoneHalfExtents.y
    }

    func snapEntityToPile(_ entity: Entity) {
        let count = pileEntities.count
        let yLift: Float = 0.0015 * Float(min(count, 40))
        let randomYaw: Float = Float.random(in: -0.12...0.12)

        entity.removeFromParent()
        pileRoot.addChild(entity)

        // lokal im pileRoot platzieren
        entity.position = .zero
        entity.position.y += yLift
        entity.orientation = simd_quatf(angle: randomYaw, axis: [0, 1, 0])

        pileEntities.append(entity)

        if pileEntities.count > 30, let first = pileEntities.first {
            first.removeFromParent()
            pileEntities.removeFirst()
        }
    }

    func push(card: UnoCard, into content: RealityViewContent) {
        do {
            let entity = try mapper.makeEntitySync(for: card)

            let count = pileEntities.count
            let yLift: Float = 0.0015 * Float(min(count, 40))
            let randomYaw: Float = Float.random(in: -0.12...0.12)

            entity.position = pileRoot.position
            entity.position.y += yLift
            entity.orientation = simd_quatf(angle: randomYaw, axis: [0, 1, 0])

            pileRoot.addChild(entity)
            pileEntities.append(entity)

            if pileEntities.count > 30, let first = pileEntities.first {
                first.removeFromParent()
                pileEntities.removeFirst()
            }
        } catch {
            print("DiscardPileRenderer.push error:", error)
        }
    }

    func clear() {
        pileEntities.forEach { $0.removeFromParent() }
        pileEntities.removeAll()
    }

    // MARK: - Random Card

    private func randomCard() -> UnoCard {
        let colors: [UnoColor] = [.red, .green, .blue, .yellow]
        let color = colors.randomElement() ?? .red

        let options: [UnoValue] = [
            .number(Int.random(in: 0...9)),
            .skip,
            .reverse,
            .drawTwo
        ]
        let value = options.randomElement() ?? .number(0)

        return UnoCard(color: color, value: value)
    }
}
