//
//  HomeSkeletons.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -200
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.28), Color.white.opacity(0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .rotationEffect(.degrees(20))
                    .offset(x: phase)
                    .blendMode(.plusLighter)
                    .allowsHitTesting(false)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 200
                }
            }
    }
}

extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}

struct CardSkeleton: View {
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.2)).frame(width: 160, height: 20)
            RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.2)).frame(width: 180, height: 44)
            RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.2)).frame(width: 80, height: 18)
            RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.2)).frame(width: 120, height: 18)
        }
        .shimmer()
    }
}

struct ChartSkeleton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.12))
            .frame(height: 130)
            .padding(.horizontal)
            .shimmer()
    }
}

struct DayScrollerSkeleton: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { _ in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.2)).frame(width: 40, height: 10)
                        RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.2)).frame(width: 36, height: 28)
                    }
                }
            }
            .padding(.horizontal)
        }
        .shimmer()
    }
}


