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

    @State private var revealedProgress: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            let cornerRadius: CGFloat = 28
            let baseShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

            baseShape
                .glassEffect(in: .rect)
                .clipShape(baseShape)
                // Subtle hairline
                .overlay(
                    baseShape
                        .inset(by: 0.5)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                // Progress stroke on top
                .overlay(alignment: .center) {
                    if !isLoading && progress > 0.001 {
                        let lineWidth: CGFloat = 6
                        ZStack {
                            // Main progress ring
                            baseShape
                                .inset(by: lineWidth / 2)
                                .trim(from: 0, to: max(0.001, min(revealedProgress, 0.999)))
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [accent.opacity(0.95), accent.opacity(0.55), accent.opacity(0.95)]),
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .shadow(color: accent.opacity(0.45), radius: 12, x: 0, y: 0)

                            // Saber tip glow
                            baseShape
                                .inset(by: lineWidth / 2)
                                .trim(from: max(0.0, revealedProgress - 0.02), to: min(1.0, revealedProgress))
                                .stroke(
                                    LinearGradient(colors: [accent.opacity(0.2), accent.opacity(0.9), accent.opacity(0.2)], startPoint: .leading, endPoint: .trailing),
                                    style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .blur(radius: 2)
                                .opacity(revealedProgress > 0 ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5), value: revealedProgress)
                    }
                }
                // Soft outer glow for depth
                .overlay {
                    if !isLoading && progress > 0.001 {
                        baseShape
                            .stroke(accent.opacity(0.10), lineWidth: 10)
                            .blur(radius: 14)
                            .opacity(min(1, Double(revealedProgress)))
                    }
                }

            Button(action: { Task { await refresh() } }) {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
                    .padding(16)
            }
        }
        .overlay(alignment: .center) {
            // Use fixed layout to avoid jumping when content changes
            ZStack(alignment: .center) {
                content()
                    .padding(28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .onAppear { animateReveal() }
        .onChange(of: progress) { animateReveal() }
        .onChange(of: isLoading) { animateReveal() }
    }

    private func animateReveal() {
        if isLoading || progress <= 0.001 {
            withAnimation(.easeInOut(duration: 0.25)) { revealedProgress = 0 }
        } else {
            withAnimation(.easeInOut(duration: 0.55)) { revealedProgress = progress }
        }
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


