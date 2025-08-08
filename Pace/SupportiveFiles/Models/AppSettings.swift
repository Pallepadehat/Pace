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
    var animationsEnabled: Bool
    var hapticsEnabled: Bool
    var dynamicBackgroundEnabled: Bool
    var ambientEdgeProgressEnabled: Bool
    var showCalories: Bool
    var showActiveMinutes: Bool
    var accentColorRawValue: String

    init(
        isHealthKitEnabled: Bool = false,
        dailyStepGoal: Int = 8000,
        distanceUnit: DistanceUnit = .metric,
        animationsEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        dynamicBackgroundEnabled: Bool = true,
        ambientEdgeProgressEnabled: Bool = true,
        showCalories: Bool = true,
        showActiveMinutes: Bool = true,
        accentColor: ThemeColor = .blue
    ) {
        self.isHealthKitEnabled = isHealthKitEnabled
        self.dailyStepGoal = dailyStepGoal
        self.distanceUnitRawValue = distanceUnit.rawValue
        self.animationsEnabled = animationsEnabled
        self.hapticsEnabled = hapticsEnabled
        self.dynamicBackgroundEnabled = dynamicBackgroundEnabled
        self.ambientEdgeProgressEnabled = ambientEdgeProgressEnabled
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
    }

    var accentTheme: ThemeColor {
        get { ThemeColor(rawValue: accentColorRawValue) ?? .blue }
        set { accentColorRawValue = newValue.rawValue }
    }

    var accentSwiftUIColor: Color { accentTheme.color }
}


