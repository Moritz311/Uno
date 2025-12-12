//
//  UnoValue.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import Foundation

/// Wert / Typ einer UNO-Karte
public enum UnoValue: Codable, Equatable {
    case number(Int)       // 0–9
    case skip
    case reverse
    case drawTwo
    case wild
    case wildDrawFour
}
