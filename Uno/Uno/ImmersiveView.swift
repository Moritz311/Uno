//
//  ImmersiveView.swift
//  Uno
//
//  Created by Schuetz Moritz - s2310237015 on 21.11.25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import UIKit

struct Card {
    var color: UIColor = .black
    var number = "0"
    
    init(color: UIColor, number: String) {
        self.color = color
        self.number = number
    }

}

struct ImmersiveView: View {
    
    let cards = [
        Card(color: .red, number: "zero"),
        Card(color: .red, number: "one"),
        Card(color: .red, number: "two"),
        Card(color: .red, number: "three"),
        Card(color: .red, number: "four"),
        Card(color: .red, number: "five"),
        Card(color: .red, number: "six"),
        Card(color: .red, number: "seven"),
        Card(color: .red, number: "eight"),
        Card(color: .blue, number: "nine"),
        Card(color: .red, number: "out"),
        Card(color: .red, number: "reverse"),
        Card(color: .green, number: "plus2"),
    ]

    var body: some View {
        RealityView { content in
            if let rootEntity = try? await Entity(named: "UnoCard",
                                                             in: realityKitContentBundle),
                           let originalCard = rootEntity.findEntity(named: "UnoCard") {

                            var manipulator = ManipulationComponent()
                            manipulator.releaseBehavior = .stay
                            manipulator.dynamics.scalingBehavior = .none

                            for card in cards {
                                    
                                let cardClone = originalCard.clone(recursive: true)

                                var xOffset: Float = 0.1
                                cardClone.position = [xOffset, 0, -1]

                                if let face = cardClone.findEntity(named: "Cube_1"),
                                   var model = face.components[ModelComponent.self] {
                                    model.materials = [
                                        SimpleMaterial(
                                            color: card.color,
                                            isMetallic: false
                                        )
                                    ]
                                   face.components.set(model)
                                }
                                
                                if let cylinder = cardClone.findEntity(named: "Cylinder"),
                                   var model = cylinder.findEntity(named: "usdPrimitiveAxis")?.components[ModelComponent.self]
                                {

                                    do {
                                            let newMaterial = try await MaterialResource.load(
                                                named: card.number,              // "one", "two", ...
                                                in: realityKitContentBundle
                                            )

                                            model.materials = [newMaterial]
                                            cylinder.components.set(model)

                                        } catch {
                                            print("Material \(card.number) konnte nicht geladen werden:", error)
                                        }
                                }
                                


                                cardClone.components.set(manipulator)

                                content.add(cardClone)
                                xOffset += 0.1
                            }
                        }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
