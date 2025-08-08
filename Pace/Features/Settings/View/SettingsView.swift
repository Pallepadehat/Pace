//
//  SettingsView.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import SwiftUI
import UIKit
import StoreKit
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    @StateObject private var healthKitManager = HealthKitManager()

    @State private var settings: AppSettings? = nil

    var body: some View {
        NavigationStack {
            Group {
                if let settings {
                    Form {
                        Section(header: Text("Health")) {
                            Toggle(isOn: Binding(
                                get: { settings.isHealthKitEnabled },
                                set: { newValue in
                                    settings.isHealthKitEnabled = newValue
                                    if newValue {
                                        Task { await healthKitManager.requestAuthorization() }
                                    }
                                }
                            )) {
                                Text("Enable Health Access")
                            }

                            HStack {
                                Label(healthKitManager.isAuthorized ? "Connected" : "Not Connected",
                                      systemImage: healthKitManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundStyle(healthKitManager.isAuthorized ? .green : .secondary)
                                Spacer()
                                Button("Manage in Health") {
                                    healthKitManager.openHealthAppForPermissions()
                                }
                            }
                        }

                        Section(header: Text("Goals")) {
                            Stepper(value: Binding(
                                get: { settings.dailyStepGoal },
                                set: { newValue in
                                    settings.dailyStepGoal = max(1000, min(newValue, 50000))
                                    if settings.hapticsEnabled { Haptics.playSuccess() }
                                }
                            ), in: 1000...50000, step: 500) {
                                HStack {
                                    Text("Daily step goal")
                                    Spacer()
                                    Text("\(settings.dailyStepGoal.formatted()) steps")
                                        .font(.headline)
                                }
                            }
                        }

                        Section(header: Text("Units")) {
                            Picker("Distance unit", selection: Binding(
                                get: { settings.distanceUnit },
                                set: { settings.distanceUnit = $0 }
                            )) {
                                ForEach(AppSettings.DistanceUnit.allCases) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                        }

                        Section(header: Text("Experience")) {
                            Toggle("Animations", isOn: Binding(
                                get: { settings.animationsEnabled },
                                set: { settings.animationsEnabled = $0 }
                            ))
                            Toggle("Haptics", isOn: Binding(
                                get: { settings.hapticsEnabled },
                                set: { settings.hapticsEnabled = $0 }
                            ))
                            Toggle("Dynamic background", isOn: Binding(
                                get: { settings.dynamicBackgroundEnabled },
                                set: { settings.dynamicBackgroundEnabled = $0 }
                            ))
                            Toggle("Ambient edge progress", isOn: Binding(
                                get: { settings.ambientEdgeProgressEnabled },
                                set: { settings.ambientEdgeProgressEnabled = $0 }
                            ))
                        }

                        Section(header: Text("Theme")) {
                            Picker("Accent color", selection: Binding(
                                get: { settings.accentTheme },
                                set: { settings.accentTheme = $0 }
                            )) {
                                ForEach(AppSettings.ThemeColor.allCases) { theme in
                                    HStack {
                                        Circle()
                                            .fill(theme.color)
                                            .frame(width: 16, height: 16)
                                        Text(theme.displayName)
                                    }
                                    .tag(theme)
                                }
                            }
                        }

                        Section(header: Text("Data")) {
                            Button(role: .destructive) {
                                resetPreferences()
                            } label: {
                                Text("Reset Preferences")
                            }
                        }

                        Section(header: Text("Support")) {
                            Button("Terms of Service") { openURLString("https://yourdomain.example/terms") }
                            Button("Privacy Policy") { openURLString("https://yourdomain.example/privacy") }
                            Button("Report a Bug") { openURLString("https://yourdomain.example/support/bug") }
                            Button("Request a Feature") { openURLString("https://yourdomain.example/support/feature") }
                            Button("Leave a Review") { requestReview() }
                        }

                        Section {
                            HStack {
                                Text("Pace")
                                Spacer()
                                Text(bundleVersionText)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("Made by")
                                Spacer()
                                Text("Patrick Jakobsen")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(
                        LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea()
                    )
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear(perform: ensureSettings)
    }

    // MARK: - Helpers
    private func openURLString(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }

    private func requestReview() {
        if #available(iOS 17.0, *) {
            // AppStore.requestReview() if provided in your project environment
            // Fallback to SKStoreReviewController
            SKStoreReviewController.requestReview()
        } else {
            SKStoreReviewController.requestReview()
        }
    }

    private var bundleVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "v\(version) (\(build))"
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

    private func resetPreferences() {
        for item in settingsList {
            modelContext.delete(item)
        }
        let created = AppSettings()
        modelContext.insert(created)
        settings = created
    }
}

private enum Haptics {
    static func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}


