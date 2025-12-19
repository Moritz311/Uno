//
//  MultiplayerManager.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import Combine

/// Platzhalter für spätere Multiplayer-Integration (GameKit / SharePlay / Network).
/// Aktuell noch ohne Logik, damit das Projekt kompiliert und die Struktur vorbereitet ist.
final class MultiplayerManager: ObservableObject {

    enum ConnectionState {
        case idle
        case hosting
        case joining
        case connected
        case error(String)
    }

    @Published var state: ConnectionState = .idle

    init() {}

    func hostGame() {
        // TODO: Später mit GameKit / SharePlay implementieren.
        state = .hosting
    }

    func joinGame() {
        // TODO: Später mit GameKit / SharePlay implementieren.
        state = .joining
    }

    func disconnect() {
        state = .idle
    }
}
