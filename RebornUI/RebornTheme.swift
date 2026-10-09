//
//  RebornTheme.swift
//  YouTube Reborn
//
//  Central place for the reimagined look. Everything is built from materials
//  and gradients that work from iOS 16 upwards, with runtime detection for
//  Liquid Glass on iOS 26+ so we can intensify the effect there without
//  promising APIs the build SDK may not have.
//

import SwiftUI

enum RebornTheme {

    /// Reborn's signature pink accent.
    static let accent = Color(red: 0.91, green: 0.12, blue: 0.54)

    /// Deep background used behind the whole menu.
    static let background = Color(red: 0.03, green: 0.03, blue: 0.05)
    static let backgroundElevated = Color(red: 0.08, green: 0.08, blue: 0.11)

    /// True when the OS can render the real Liquid Glass material (iOS 26+).
    static var usesLiquidGlass: Bool {
        NSClassFromString("UIGlassEffect") != nil
    }

    static var cardCornerRadius: CGFloat {
        usesLiquidGlass ? 30 : 24
    }

    static func tint(_ tint: RebornTint) -> Color {
        switch tint {
        case .red: return Color(red: 0.96, green: 0.26, blue: 0.21)
        case .pink: return Color(red: 0.93, green: 0.24, blue: 0.52)
        case .purple: return Color(red: 0.61, green: 0.35, blue: 0.96)
        case .blue: return Color(red: 0.20, green: 0.51, blue: 0.98)
        case .teal: return Color(red: 0.19, green: 0.78, blue: 0.78)
        case .green: return Color(red: 0.20, green: 0.78, blue: 0.42)
        case .orange: return Color(red: 1.00, green: 0.58, blue: 0.20)
        case .gray: return Color(red: 0.62, green: 0.62, blue: 0.68)
        }
    }
}

/// Glass card background used by every panel in the new menu.
struct RebornCardBackground: View {
    var cornerRadius: CGFloat = RebornTheme.cardCornerRadius

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        shape
            .fill(.ultraThinMaterial)
            .overlay(
                shape.stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func rebornCard(cornerRadius: CGFloat = RebornTheme.cardCornerRadius) -> some View {
        background(RebornCardBackground(cornerRadius: cornerRadius))
    }
}
