import Foundation
import RealityKit
import RealityKitContent
internal import UIKit

final class UnoCardEntityMapper {

    static let shared = UnoCardEntityMapper()

    private init() {}

    // MARK: - Entity Builder

    func makeEntitySync(for card: UnoCard) throws -> Entity {

        let entity = try EntityPool.shared.makeCardEntitySync()
        
        var manipulationComponent = ManipulationComponent()
        manipulationComponent.releaseBehavior = .stay
        manipulationComponent.dynamics.scalingBehavior = .none
        entity.components.set(manipulationComponent)

        // ------------------------------------------
        // 1) Hintergrund einfärben
        // ------------------------------------------
        if let face = entity.findEntity(named: "Cube_1"),
           var model = face.components[ModelComponent.self]
        {
            let material = SimpleMaterial(
                color: card.color.uiColor(),
                roughness: 0.9,
                isMetallic: false
            )
            model.materials = [material]
            face.components.set(model)
        }
        // ------------------------------------------
        // 2) Symbol / Zahl Textur setzen (PNG)
        // ------------------------------------------
        if let symbol = entity.findEntity(named: "usdPrimitiveAxis"),
           var model = symbol.components[ModelComponent.self]
        {
            let matName = card.materialName()

            if let image = UIImage(named: matName)!.cgImage,
               let texture = try? TextureResource(image: image, options: .init(semantic: .hdrColor)) {
                

                var unlit = UnlitMaterial()

                // WICHTIG: TextureResource → MaterialParameters.Texture
                let wrappedTexture = MaterialParameters.Texture(texture)

                unlit.color = .init(texture: wrappedTexture)

                model.materials = [unlit]
                symbol.components.set(model)

            } else {
                print("⚠️ Textur \(matName) konnte nicht geladen werden.")
            }
        }

        // ------------------------------------------
        // 3) Skalierung & Name
        // ------------------------------------------
        entity.name = card.id.uuidString

        return entity
    }
}


// MARK: - Mapping-Funktionen für Kartennamen

extension UnoCard {

    func materialName() -> String {
        switch value {
        case .number(let n): return numberName(n)
        case .skip: return "skip"
        case .reverse: return "reverse"
        case .drawTwo: return "plus2"
        case .wild: return "wild"
        case .wildDrawFour: return "plus4"
        }
    }

    private func numberName(_ n: Int) -> String {
        switch n {
        case 0: return "zero"
        case 1: return "one"
        case 2: return "two"
        case 3: return "three"
        case 4: return "four"
        case 5: return "five"
        case 6: return "six"
        case 7: return "seven"
        case 8: return "eight"
        case 9: return "nine"
            
        default: return "zero"
        }
    }
}
