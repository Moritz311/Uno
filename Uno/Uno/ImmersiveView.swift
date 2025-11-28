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
        Card(color: .red, number: "nine"),
    ]

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "UnoCard", in: realityKitContentBundle) {
                var manipulator = ManipulationComponent()
                manipulator.releaseBehavior = .stay
                manipulator.dynamics.scalingBehavior = .none
                
                var cardEntity = immersiveContentEntity.findEntity(named: "UnoCard")
                var test = cardEntity?.findEntity(named: "Cube_1")
                test?.components[ModelComponent.self]?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                
                var xOffset: Float = 0.01
                cardEntity?.components.set(manipulator)
                
                var cloned = cardEntity?.clone(recursive: true)
                cloned?.position.x = xOffset
                test = cloned?.findEntity(named: "Cube_1")
                test?.components[ModelComponent.self]?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                cloned?.components.set(manipulator)
                
                xOffset += 0.01
                
                
                for card in cards {
                    
                }
                
                content.add(immersiveContentEntity)
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
