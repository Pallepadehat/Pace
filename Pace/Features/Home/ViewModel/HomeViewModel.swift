//
//  HomeViewModel.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var stepsToday: Int = 0
    @Published var distanceTodayMeters: Double = 0
    @Published var hourlySteps: [HourPoint] = []
    @Published var last7Days: [DayPoint] = []
    @Published var selectedDate: Date = Date()
    @Published var isLoading: Bool = true

    private let health = HealthKitManager()

    var selectedDayFormatted: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE\nMMMM d"
        return df.string(from: selectedDate)
    }

    func distanceString(unit: AppSettings.DistanceUnit) -> String {
        switch unit {
        case .metric:
            let km = distanceTodayMeters / 1000
            return String(format: "%.2f km", km)
        case .imperial:
            let miles = distanceTodayMeters / 1609.34
            return String(format: "%.2f mi", miles)
        }
    }

    func progressFraction(goal: Int) -> CGFloat {
        guard goal > 0 else { return 0 }
        return CGFloat(min(1.0, Double(stepsToday) / Double(goal)))
    }

    func onAppear() async {
        if !health.isAuthorized { await health.requestAuthorization() }
        await refresh()
    }

    func refresh(for date: Date? = nil) async {
        if let date { selectedDate = date }
        do {
            isLoading = true
            async let steps = health.fetchSteps(for: selectedDate)
            async let dist = health.fetchDistanceMeters(for: selectedDate)
            async let hourly = health.fetchHourlySteps(for: selectedDate)
            async let daily = health.fetchDailySteps(forLast: 7)
            let (s, d, h, last) = try await (steps, dist, hourly, daily)
            stepsToday = s
            distanceTodayMeters = d
            hourlySteps = h.map { HourPoint(date: $0.0, steps: $0.1) }
            last7Days = last.map { DayPoint(date: $0.0, steps: $0.1) }
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

// MARK: - Data models for charts
struct HourPoint: Identifiable {
    let date: Date
    let steps: Int
    var id: Date { date }
}

struct DayPoint: Identifiable {
    let date: Date
    let steps: Int
    var id: Date { date }
}


