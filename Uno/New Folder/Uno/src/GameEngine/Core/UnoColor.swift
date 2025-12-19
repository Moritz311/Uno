//
//  UnoColor.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation
import UIKit

/// Farben im UNO-Spiel
public enum UnoColor: String, Codable, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case wild   // für Wild & +4

    public var isWild: Bool {
        self == .wild
    }
} 

/// Mapping auf UIKit-Farben für RealityKit
extension UnoColor {
    func uiColor() -> UIColor {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .wild: return .black
        }
    }
}
