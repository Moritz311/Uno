//
//  EntityPool.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import RealityKit
import RealityKitContent

/// Pool für UNO-Kartenmodelle, damit Modelle nicht mehrfach neu geladen werden.
final class EntityPool {

    static let shared = EntityPool()

    private var cachedCardModel: Entity?

    private init() {}

    /// SYNCHRONES Laden eines Kartenmodells für visionOS 1.x
    func makeCardEntitySync() throws -> Entity {

        // Modell nur einmal laden
        if let cached = cachedCardModel {
            return cached.clone(recursive: true)
        }

        // UNO-Kartenmodell laden (Name muss exakt so sein wie in RealityKitContent)
        let model = try Entity.load(named: "UnoCard", in: realityKitContentBundle)

        cachedCardModel = model
        return model.clone(recursive: true)
    }
}
