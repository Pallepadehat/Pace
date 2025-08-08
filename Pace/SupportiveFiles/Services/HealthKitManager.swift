//
//  HealthKitManager.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import Foundation
import HealthKit
import Combine
import UIKit

@MainActor
final class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var isAuthorized: Bool = false

    var isHealthDataAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { types.insert(steps) }
        if let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) { types.insert(distance) }
        if let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { types.insert(activeEnergy) }
        if let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) { types.insert(exerciseTime) }
        return types
    }

    func requestAuthorization() async {
        guard isHealthDataAvailable else { return }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            // There's no perfect read-authorization status API; assume success after no error
            isAuthorized = true
        } catch {
            isAuthorized = false
        }
    }

    func openHealthAppForPermissions() {
        guard let url = URL(string: "x-apple-health://") else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Queries
    func fetchSteps(for date: Date) async throws -> Int {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: date.startOfDay, end: date.endOfDay, options: [.strictStartDate])
        let sum = try await statisticsSum(for: type, predicate: predicate)
        return Int(sum)
    }

    func fetchDistanceMeters(for date: Date) async throws -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: date.startOfDay, end: date.endOfDay, options: [.strictStartDate])
        let sum = try await statisticsSum(for: type, unit: .meter(), predicate: predicate)
        return sum
    }

    func fetchHourlySteps(for date: Date) async throws -> [(Date, Int)] {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else { return [] }
        let interval = DateComponents(hour: 1)
        let anchor = date.startOfDay
        let predicate = HKQuery.predicateForSamples(withStart: date.startOfDay, end: date.endOfDay, options: [.strictStartDate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchor, intervalComponents: interval)
            query.initialResultsHandler = { _, collection, error in
                if let error { return continuation.resume(throwing: error) }
                guard let collection else { return continuation.resume(returning: []) }
                var results: [(Date, Int)] = []
                collection.enumerateStatistics(from: date.startOfDay, to: date.endOfDay) { stats, _ in
                    let value = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    results.append((stats.startDate, Int(value)))
                }
                continuation.resume(returning: results)
            }
            healthStore.execute(query)
        }
    }

    func fetchDailySteps(forLast days: Int) async throws -> [(Date, Int)] {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else { return [] }
        let end = Date().endOfDay
        let start = Calendar.current.date(byAdding: .day, value: -days + 1, to: Date().startOfDay) ?? Date().startOfDay
        let interval = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [.strictStartDate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: start, intervalComponents: interval)
            query.initialResultsHandler = { _, collection, error in
                if let error { return continuation.resume(throwing: error) }
                guard let collection else { return continuation.resume(returning: []) }
                var results: [(Date, Int)] = []
                collection.enumerateStatistics(from: start, to: end) { stats, _ in
                    let value = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    results.append((stats.startDate, Int(value)))
                }
                continuation.resume(returning: results)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Helpers
    private func statisticsSum(for type: HKQuantityType, unit: HKUnit = .count(), predicate: NSPredicate?) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error { continuation.resume(throwing: error); return }
                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
}

// MARK: - Date Helpers
fileprivate extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var endOfDay: Date {
        let start = startOfDay
        return Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? self
    }
}


