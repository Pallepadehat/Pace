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
                                    persist()
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
                                    Haptics.playSuccess()
                                    persist()
                                }
                            ), in: 1000...50000, step: 500) {
                                HStack {
                                    Text("Daily step goal")
                                    Spacer()
                                    Text("\(settings.dailyStepGoal.formatted()) steps")
                                        .contentTransition(.numericText(value: Double(settings.dailyStepGoal)))
                                        .font(.headline)
                                }
                            }
                        }

                        Section(header: Text("Units")) {
                            Picker("Distance unit", selection: Binding(
                                get: { settings.distanceUnit },
                                set: { settings.distanceUnit = $0; persist() }
                            )) {
                                ForEach(AppSettings.DistanceUnit.allCases) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                        }

                        Section(header: Text("Theme")) {
                            Picker("Accent color", selection: Binding(
                                get: { settings.accentTheme },
                                set: { newTheme in
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        settings.accentTheme = newTheme
                                    }
                                    persist()
                                }
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
                            LabeledButton(title: "Terms of Service", systemImage: "doc.text") {
                                openURLString("https://yourdomain.example/terms")
                            }
                            LabeledButton(title: "Privacy Policy", systemImage: "lock.shield") {
                                openURLString("https://yourdomain.example/privacy")
                            }
                            LabeledButton(title: "Report a Bug", systemImage: "ladybug") {
                                openURLString("https://yourdomain.example/support/bug")
                            }
                            LabeledButton(title: "Request a Feature", systemImage: "sparkles") {
                                openURLString("https://yourdomain.example/support/feature")
                            }
                            LabeledButton(title: "Leave a Review", systemImage: "star.bubble") {
                                requestReview()
                            }
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
                    .background(gradientBackground)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear(perform: ensureSettings)
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

    private func persist() {
        do { try modelContext.save() } catch { }
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

private struct LabeledButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
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


