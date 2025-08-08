//
//  AppSettings.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class AppSettings {
    // Preferences
    var isHealthKitEnabled: Bool
    var dailyStepGoal: Int
    var distanceUnitRawValue: String
    var showCalories: Bool
    var showActiveMinutes: Bool
    var accentColorRawValue: String

    init(
        isHealthKitEnabled: Bool = false,
        dailyStepGoal: Int = 8000,
        distanceUnit: DistanceUnit = .metric,
        showCalories: Bool = true,
        showActiveMinutes: Bool = true,
        accentColor: ThemeColor = .blue
    ) {
        self.isHealthKitEnabled = isHealthKitEnabled
        self.dailyStepGoal = dailyStepGoal
        self.distanceUnitRawValue = distanceUnit.rawValue
        self.showCalories = showCalories
        self.showActiveMinutes = showActiveMinutes
        self.accentColorRawValue = accentColor.rawValue
    }

    enum DistanceUnit: String, CaseIterable, Identifiable {
        case metric
        case imperial

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .metric: return "Metric (km)"
            case .imperial: return "Imperial (mi)"
            }
        }
    }

    var distanceUnit: DistanceUnit {
        get { DistanceUnit(rawValue: distanceUnitRawValue) ?? .metric }
        set { distanceUnitRawValue = newValue.rawValue }
    }

    enum ThemeColor: String, CaseIterable, Identifiable {
        case blue, purple, pink, orange, red, green, teal, indigo, yellow, mint

        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .blue: return "Blue"
            case .purple: return "Purple"
            case .pink: return "Pink"
            case .orange: return "Orange"
            case .red: return "Red"
            case .green: return "Green"
            case .teal: return "Teal"
            case .indigo: return "Indigo"
            case .yellow: return "Yellow"
            case .mint: return "Mint"
            }
        }

        var color: Color {
            switch self {
            case .blue: return .blue
            case .purple: return .purple
            case .pink: return .pink
            case .orange: return .orange
            case .red: return .red
            case .green: return .green
            case .teal: return .teal
            case .indigo: return .indigo
            case .yellow: return .yellow
            case .mint: return .mint
            }
        }

        func gradientColors(for colorScheme: ColorScheme) -> [Color] {
            // Subtle paired gradients by theme; balanced for light/dark
            let opacityTop: Double = colorScheme == .dark ? 0.20 : 0.16
            let opacityBottom: Double = colorScheme == .dark ? 0.24 : 0.18
            switch self {
            case .blue:
                return [Color.blue.opacity(opacityTop), Color.purple.opacity(opacityBottom)]
            case .purple:
                return [Color.purple.opacity(opacityTop), Color.indigo.opacity(opacityBottom)]
            case .pink:
                return [Color.pink.opacity(opacityTop), Color.purple.opacity(opacityBottom)]
            case .orange:
                return [Color.orange.opacity(opacityTop), Color.red.opacity(opacityBottom)]
            case .red:
                return [Color.red.opacity(opacityTop), Color.pink.opacity(opacityBottom)]
            case .green:
                return [Color.green.opacity(opacityTop), Color.teal.opacity(opacityBottom)]
            case .teal:
                return [Color.teal.opacity(opacityTop), Color.blue.opacity(opacityBottom)]
            case .indigo:
                return [Color.indigo.opacity(opacityTop), Color.blue.opacity(opacityBottom)]
            case .yellow:
                return [Color.yellow.opacity(colorScheme == .dark ? 0.18 : 0.12), Color.orange.opacity(opacityBottom)]
            case .mint:
                return [Color.mint.opacity(opacityTop), Color.teal.opacity(opacityBottom)]
            }
        }
    }

    var accentTheme: ThemeColor {
        get { ThemeColor(rawValue: accentColorRawValue) ?? .blue }
        set { accentColorRawValue = newValue.rawValue }
    }

    var accentSwiftUIColor: Color { accentTheme.color }
}


