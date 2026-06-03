// ◎ Kings-Chamber — OBIWANFaceView.swift
// Watch content view — wraps OBIWANWatchFace with live heart rate via HealthKit.

import SwiftUI
import HealthKit
import DOJOShared
import DOJOUI

struct OBIWANFaceView: View {
    @ObservedObject var state: OBIWANState
    @State private var heartRate: Double? = nil
    @State private var hrv: Double? = nil

    private let healthStore = HKHealthStore()

    var body: some View {
        OBIWANWatchFace(state: state, heartRate: heartRate, hrv: hrv)
            .ignoresSafeArea()
            .task { await requestHealthAccess() }
    }

    private func requestHealthAccess() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let hrType = HKQuantityType(.heartRate)
        let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [hrType, hrvType])
            observeHeartRate()
            observeHRV()
        } catch {
            // HealthKit unavailable or denied — watch face runs without biometrics
        }
    }

    private func observeHeartRate() {
        let hrType = HKQuantityType(.heartRate)
        let query = HKAnchoredObjectQuery(
            type: hrType,
            predicate: HKQuery.predicateForSamples(withStart: .distantPast, end: nil),
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { _, samples, _, _, _ in
            guard let sample = (samples as? [HKQuantitySample])?.last else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            Task { @MainActor in self.heartRate = bpm }
        }
        query.updateHandler = { _, samples, _, _, _ in
            guard let sample = (samples as? [HKQuantitySample])?.last else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            Task { @MainActor in self.heartRate = bpm }
        }
        healthStore.execute(query)
    }

    private func observeHRV() {
        let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: hrvType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = (samples as? [HKQuantitySample])?.first else { return }
            let ms = sample.quantity.doubleValue(for: .init(from: "ms"))
            Task { @MainActor in self.hrv = ms }
        }
        healthStore.execute(query)
    }
}
