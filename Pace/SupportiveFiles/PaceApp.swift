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

    @State private var settings: AppSettings? = nil

    var body: some View {
        Group {
            if let settings {
                ContentView()
                    .tint(settings.accentSwiftUIColor)
            } else {
                ContentView()
                    .task { ensureSettings() }
            }
        }
        .onAppear { ensureSettings() }
    }

    private func ensureSettings() {
        if let existing = settingsList.first {
            settings = existing
        } else {
            let created = AppSettings()
            modelContext.insert(created)
            settings = created
        }
    }
}
