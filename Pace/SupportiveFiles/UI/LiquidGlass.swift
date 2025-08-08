//
//  LiquidGlass.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import SwiftUI

struct LiquidGlass: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .glassBackgroundEffect()
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 8)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.08), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
            )
    }
}

extension View {
    // Adopt Liquid Glass – polished glassy look
    func adoptLiquidGlass(cornerRadius: CGFloat = 20) -> some View {
        modifier(LiquidGlass(cornerRadius: cornerRadius))
    }

    // Liquid Glass background helper
    func liquidGlassBackground() -> some View {
        background(
            LinearGradient(colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }

    // Explicit glass effect when needed
    func glassBackgroundEffect() -> some View {
        self.background(.ultraThinMaterial)
            .overlay(
                LinearGradient(colors: [Color.white.opacity(0.06), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
}


