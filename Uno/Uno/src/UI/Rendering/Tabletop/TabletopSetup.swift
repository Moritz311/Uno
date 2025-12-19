//
//  TableTopSetup.swift
//  Uno
//
//  Created by Fabian Neubacher on 12.12.25.
//
//


import TabletopKit
import RealityKit
import Spatial
internal import UIKit
import _RealityKit_SwiftUI


@MainActor
final class TabletopSetup {

    var tableSetup: TableSetup
    let cardStockGroup: CardStockGroup

    init(content: RealityViewContent) {

        //Tisch logisch
        tableSetup = TableSetup(
            tabletop: Table(
                shape: .rectangular(
                    width: 1.2,
                    height: 0.85,
                    thickness: 0
                )
            )
        )

        // Seat (zentriert zur Kartenreihe)
        let seat = SimpleSeat(
            id: TableSeatIdentifier(0),
            pose: .init(
                position: .init(x: 0.0, z: 0.6),
                rotation: .degrees(180)
            )
        )
        tableSetup.add(seat: seat)

        // Kartenstapel (APU) – ebenfalls relativ zur Kartenmitte
        cardStockGroup = CardStockGroup(
            id: EquipmentIdentifier(1),
            pose: .init(
                position: .init(x: 0.0, z: -0.3),
                rotation: .degrees(90)
            )
        )
        tableSetup.add(equipment: cardStockGroup)

       //Tisch sichtbar
        let tableRoot = Entity()
        content.add(tableRoot)

        //  WICHTIG: exakt gleiche Referenz wie CardRenderer
        let tableTopThickness: Float = 0.04

        tableRoot.position = SIMD3(
            x: 0.0,
            y: 0.5 - tableTopThickness / 2 - 0.01, // knapp unter Karten
            z: -1.0
        )

        
        var wood = PhysicallyBasedMaterial()
        wood.baseColor = .init(
            tint: .init(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
        )
        wood.roughness = 0.6
        wood.metallic  = 0.0

      
        let top = ModelEntity(
            mesh: MeshResource.generateBox(
                width: 1.2,
                height: tableTopThickness,
                depth: 0.85
            ),
            materials: [wood]
        )
        top.position = .zero
        tableRoot.addChild(top)

 
        let legHeight: Float = 0.65
        let legThickness: Float = 0.05

        func leg(x: Float, z: Float) -> ModelEntity {
            let leg = ModelEntity(
                mesh: MeshResource.generateBox(
                    width: legThickness,
                    height: legHeight,
                    depth: legThickness
                ),
                materials: [wood]
            )
            leg.position = SIMD3(
                x,
                -legHeight / 2 - tableTopThickness / 2,
                z
            )
            return leg
        }

        let xOff: Float = 0.55
        let zOff: Float = 0.38

        tableRoot.addChild(leg(x:  xOff, z:  zOff))
        tableRoot.addChild(leg(x: -xOff, z:  zOff))
        tableRoot.addChild(leg(x:  xOff, z: -zOff))
        tableRoot.addChild(leg(x: -xOff, z: -zOff))
    }
}

// MARK: - Helper Types

extension EquipmentIdentifier {
    static var tableID: Self { .init(0) }
}

struct Table: Tabletop {
    var shape: TabletopShape
    var id: EquipmentIdentifier = .tableID
}

struct CardStockGroup: Equipment {
    let id: ID
    let initialState: BaseEquipmentState

    init(id: ID, pose: TableVisualState.Pose2D) {
        self.id = id
        self.initialState = .init(
            parentID: .tableID,
            seatControl: .any,
            pose: pose
        )
    }
}

struct SimpleSeat: TableSeat {
    let id: ID
    var initialState: TableSeatState

    init(id: TableSeatIdentifier, pose: TableVisualState.Pose2D) {
        self.id = id
        self.initialState = .init(pose: pose)
    }
}
