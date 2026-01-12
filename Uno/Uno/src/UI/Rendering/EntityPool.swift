//
//  EntityPool.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import RealityKit
import RealityKitContent

final class EntityPool {

    static let shared = EntityPool()

    private var cachedCardModel: Entity?

    private init() {}

    func makeCardEntitySync() throws -> Entity {

        // Modell nur einmal laden
        if let cached = cachedCardModel {
            return cached.clone(recursive: true)
        }

        let model = try Entity.load(named: "UnoCard", in: realityKitContentBundle)

        cachedCardModel = model
        return model.clone(recursive: true)
    }
}
