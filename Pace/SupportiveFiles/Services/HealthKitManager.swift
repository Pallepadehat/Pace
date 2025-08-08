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
}


