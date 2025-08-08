//
//  HomeView.swift
//  Pace
//
//  Created by Patrick Jakobsen on 08/08/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Placeholder content — will be replaced with live stats later
                Text("Today")
                    .font(.largeTitle.weight(.bold))
                Text("0 steps")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .contentTransition(.numericText(value: 0))
                    .monospacedDigit()
                    .animation(.easeInOut(duration: 0.4), value: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(gradientBackground)
            .navigationTitle("Steps")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }

    @Environment(\.colorScheme) private var colorScheme
    private var gradientBackground: some View {
        let theme = settingsList.first?.accentTheme ?? .blue
        let colors = theme.gradientColors(for: colorScheme)
        let themeKey = theme.rawValue + (colorScheme == .dark ? "_d" : "_l")
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: themeKey)
    }
}

#Preview {
    HomeView()
}
