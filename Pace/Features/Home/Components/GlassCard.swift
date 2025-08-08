//
//  GlassCard.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let accent: Color
    let progress: CGFloat
    let isLoading: Bool
    let content: () -> Content
    let refresh: () async -> Void

    init(accent: Color, progress: CGFloat, isLoading: Bool, @ViewBuilder content: @escaping () -> Content, refresh: @escaping () async -> Void) {
        self.accent = accent
        self.progress = progress
        self.isLoading = isLoading
        self.content = content
        self.refresh = refresh
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .glassBackgroundEffect()
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [Color.white.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        .blendMode(.plusLighter)
                )
                .background(ProgressGlow(progress: progress, color: accent))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            Button(action: { Task { await refresh() } }) {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
                    .padding(16)
            }
        }
        .overlay(
            content()
                .padding(28)
        )
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 360)
    }
}

struct ProgressGlow: View {
    let progress: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let rect = proxy.size
            let radius: CGFloat = 28
            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(color.opacity(0.35), lineWidth: 3)
                    .shadow(color: color.opacity(0.7), radius: 28, x: 0, y: 0)
                    .mask(progressMask(in: rect))
                    .animation(.easeInOut(duration: 0.6), value: progress)
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(color.opacity(0.08), lineWidth: 12)
                    .blur(radius: 12)
                    .mask(progressMask(in: rect))
            }
        }
    }

    private func progressMask(in size: CGSize) -> some View {
        let _ = (size.width + size.height) * 2 // perimeter (unused var removed)
        return RoundedRectangle(cornerRadius: 28, style: .continuous)
            .trim(from: 0, to: min(0.999, progress))
            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .frame(width: size.width, height: size.height)
            .offset(x: 0, y: 0)
    }
}


