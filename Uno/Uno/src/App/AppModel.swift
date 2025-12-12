//
//  AppModel.swift
//  Uno
//
//  Created by Schuetz Moritz - s2310237015 on 21.11.25.
//


import SwiftUI
import Observation   // ← add this

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
