//
//  PaceApp.swift
//  Pace
//
//  Created by Patrick Jakobsen on 08/08/2025.
//

import SwiftUI
import SwiftData

@main
struct PaceApp: App {
    var body: some Scene {
        WindowGroup {
            Root()
        }
        .modelContainer(for: [AppSettings.self])
    }
}

private struct Root: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    var body: some View {
        let accentKey = settingsList.first?.accentTheme.rawValue ?? "blue"
        let accentColor = settingsList.first?.accentSwiftUIColor ?? .blue

        return ContentView()
            .tint(accentColor)
            .animation(.easeInOut(duration: 0.35), value: accentKey)
            .task { ensureSettings() }
            .onAppear { ensureSettings() }
    }

    private func ensureSettings() {
        if settingsList.first == nil {
            let created = AppSettings()
            modelContext.insert(created)
        }
    }
}
