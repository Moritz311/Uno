//
//  WoldColorPicker.swift
//  Uno
//
//  Created by Fabian Neubacher on 11.12.25.
//

import SwiftUI

/// Overlay, das erscheint, wenn der Spieler eine Wild- oder +4-Karte spielt.
/// Ermöglicht Auswahl der neuen Farbe.
struct WildColorPicker: View {

    var onSelect: (UnoColor) -> Void
    var onCancel: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            Text("Wähle eine Farbe")
                .font(.headline)
                .padding(.top, 8)

            HStack(spacing: 16) {
                colorButton(color: .red, label: "Rot")
                colorButton(color: .blue, label: "Blau")
            }
            HStack(spacing: 16) {
                colorButton(color: .green, label: "Grün")
                colorButton(color: .yellow, label: "Gelb")
            }

            Button("Abbrechen") {
                onCancel()
            }
            .padding(.bottom, 8)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }

    private func colorButton(color: UnoColor, label: String) -> some View {
        Button {
            onSelect(color)
        } label: {
            Text(label)
                .font(.headline)
                .padding()
                .frame(width: 100)
                .background(backgroundColor(for: color))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }

    private func backgroundColor(for color: UnoColor) -> Color {
        switch color {
        case .red:    return .red
        case .blue:   return .blue
        case .green:  return .green
        case .yellow: return .yellow
        case .wild:   return .black
        }
    }
}
