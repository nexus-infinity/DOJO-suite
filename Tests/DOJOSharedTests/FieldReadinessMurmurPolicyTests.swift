import Foundation
import Testing
@testable import DOJOShared

@Suite("Apple Watch readiness murmur policy")
struct FieldReadinessMurmurPolicyTests {
    private let calendar: Calendar
    private let evaluatedAt: Date

    init() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.calendar = calendar
        self.evaluatedAt = Date(timeIntervalSince1970: 1_789_473_600) // 2026-09-15 12:00:00Z
    }

    @Test("High readiness leaves Watch setpoints unchanged")
    func highReadiness() throws {
        let cue = derive(hrv: 55, restingHeartRate: 60)
        let admission = try evaluate(cue)

        #expect(cue.level == .high)
        #expect(admission.decision == .normal)
        #expect(admission.correctionAction == nil)
        #expect(admission.adjustedSetpoints == FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy.setpoints)
    }

    @Test("Medium readiness slightly reduces open time")
    func mediumReadiness() throws {
        let cue = derive(hrv: 50, restingHeartRate: 60)
        let admission = try evaluate(cue)

        #expect(cue.level == .medium)
        #expect(admission.decision == .dampened)
        #expect(admission.correctionAction == .dampenHaptics)
        #expect(abs(admission.adjustedSetpoints.maxOpenMinutes - 0.9) < 0.000_001)
        #expect(admission.adjustedSetpoints.maxRequestsPerMinute == 1)
    }

    @Test("Low readiness applies strong setpoint reductions")
    func lowReadinessSetpoints() throws {
        let cue = derive(hrv: 39, restingHeartRate: 60)
        let adjusted = FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy.adjustedSetpoints(for: cue.level)

        #expect(cue.level == .low)
        #expect(abs(adjusted.maxOpenMinutes - 0.7) < 0.000_001)
        #expect(abs(adjusted.maxRequestsPerMinute - 0.5) < 0.000_001)
    }

    @Test("One low evaluation stages but does not persistently dampen")
    func singleLowEvaluation() throws {
        let admission = try evaluate(derive(hrv: 39, restingHeartRate: 60))

        #expect(admission.decision == .normal)
        #expect(admission.correctionAction == nil)
        #expect(admission.reason == "PASS.Readiness.LowObservedAwaitingConfirmation")
    }

    @Test("Two consecutive low evaluations admit haptic dampening")
    func consecutiveLowEvaluations() throws {
        let cue = derive(hrv: 39, restingHeartRate: 60, previousLowCount: 1)
        let admission = try evaluate(cue)

        #expect(cue.consecutiveLowEvaluations == 2)
        #expect(admission.decision == .dampened)
        #expect(admission.correctionAction == .dampenHaptics)
    }

    @Test(
        "Invalid evidence returns unknown and holds",
        arguments: [
            ReadinessDataQuality.missing,
            .stale,
            .insufficientSamples,
            .nonpositive,
            .unreliable
        ]
    )
    func invalidEvidenceHolds(expectedQuality: ReadinessDataQuality) throws {
        let cue: ReadinessCue
        switch expectedQuality {
        case .missing:
            cue = derive(hrv: nil, restingHeartRate: 60)
        case .stale:
            cue = derive(hrv: 50, restingHeartRate: 60, restingHeartRateDayOffset: -2)
        case .insufficientSamples:
            cue = derive(hrv: 50, restingHeartRate: 60, baselineCount: 13)
        case .nonpositive:
            cue = derive(hrv: 0, restingHeartRate: 60)
        case .unreliable:
            cue = derive(hrv: 50, restingHeartRate: 60, hrvIsReliable: false)
        case .valid:
            Issue.record("Valid quality is not an invalid-evidence test argument")
            return
        }
        let admission = try evaluate(cue)

        #expect(cue.level == .unknown)
        #expect(cue.quality == expectedQuality)
        #expect(admission.decision == .held)
        #expect(admission.correctionAction == .hold)
        #expect(admission.adjustedSetpoints == FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy.setpoints)
    }

    @Test("Median baseline resists an outlier")
    func baselineUsesMedian() throws {
        var hrvBaseline = baselineSamples(prefix: "hrv", value: 50, count: 14)
        hrvBaseline[0] = sample(id: "hrv-outlier", value: 500, dayOffset: -2)
        let cue = ReadinessDerivation.derive(
            hrvSample: sample(id: "hrv-current", value: 50, hourOffset: -4),
            restingHeartRateSample: sample(id: "rhr-current", value: 60, dayOffset: -1),
            hrvBaselineSamples: hrvBaseline,
            restingHeartRateBaselineSamples: baselineSamples(prefix: "rhr", value: 60, count: 14),
            evaluatedAt: evaluatedAt,
            calendar: calendar
        )

        #expect(cue.baselineHRVMilliseconds == 50)
        #expect(cue.level == .medium)
    }

    @Test("Over-authorized Watch policy fails closed")
    func hostilePolicyHolds() throws {
        let base = FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy
        let hostile = FieldMurmurPolicy(
            surfaceID: base.surfaceID,
            mirroredGeometryPointers: base.mirroredGeometryPointers,
            setpoints: base.setpoints,
            toleranceBands: base.toleranceBands,
            correctionActions: base.correctionActions,
            evidencePointer: base.evidencePointer,
            authorityCeiling: base.authorityCeiling,
            mayRedefineGeometry: true
        )
        let admission = FieldReadinessMurmurPolicy.evaluate(
            cue: derive(hrv: 55, restingHeartRate: 60),
            policy: hostile,
            sourceSurface: AppleWatchContract.appleWatchBiometric,
            targetSurface: try #require(FieldSurfaceCoordinationCatalog.surfaceNode(for: "watch_ultra_murmur"))
        )

        #expect(admission.decision == .held)
        #expect(admission.blockedLaw == .conservation)
        #expect(admission.correctionAction == .hold)
    }

    @Test("Cue, admission, and evidence receipt round trip through Codable")
    func codableRoundTrip() throws {
        let cue = derive(hrv: 39, restingHeartRate: 67, previousLowCount: 1)
        let admission = try evaluate(cue)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        #expect(try decoder.decode(ReadinessCue.self, from: encoder.encode(cue)) == cue)
        #expect(try decoder.decode(FieldReadinessMurmurAdmission.self, from: encoder.encode(admission)) == admission)
        #expect(try decoder.decode(FieldReadinessEvidenceReceipt.self, from: encoder.encode(admission.receipt)) == admission.receipt)
        #expect(admission.receipt.sourceSurfaceID == "apple_watch_biometric")
        #expect(admission.receipt.targetSurfaceID == "watch_ultra_murmur")
        #expect(admission.receipt.interpretation.contains("not a medical diagnosis"))
    }

    private func evaluate(_ cue: ReadinessCue) throws -> FieldReadinessMurmurAdmission {
        FieldReadinessMurmurPolicy.evaluate(
            cue: cue,
            policy: FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy,
            sourceSurface: AppleWatchContract.appleWatchBiometric,
            targetSurface: try #require(FieldSurfaceCoordinationCatalog.surfaceNode(for: "watch_ultra_murmur"))
        )
    }

    private func derive(
        hrv: Double?,
        restingHeartRate: Double?,
        previousLowCount: Int = 0,
        baselineCount: Int = 14,
        restingHeartRateDayOffset: Int = -1,
        hrvIsReliable: Bool = true
    ) -> ReadinessCue {
        ReadinessDerivation.derive(
            hrvSample: hrv.map {
                sample(id: "hrv-current", value: $0, hourOffset: -4, isReliable: hrvIsReliable)
            },
            restingHeartRateSample: restingHeartRate.map {
                sample(id: "rhr-current", value: $0, dayOffset: restingHeartRateDayOffset)
            },
            hrvBaselineSamples: baselineSamples(prefix: "hrv", value: 50, count: baselineCount),
            restingHeartRateBaselineSamples: baselineSamples(prefix: "rhr", value: 60, count: baselineCount),
            evaluatedAt: evaluatedAt,
            previousConsecutiveLowEvaluations: previousLowCount,
            calendar: calendar
        )
    }

    private func baselineSamples(prefix: String, value: Double, count: Int) -> [ReadinessMetricSample] {
        (0..<count).map { index in
            sample(id: "\(prefix)-\(index)", value: value, dayOffset: -(index + 2))
        }
    }

    private func sample(
        id: String,
        value: Double,
        dayOffset: Int = 0,
        hourOffset: Int = 0,
        isReliable: Bool = true
    ) -> ReadinessMetricSample {
        let day = calendar.date(byAdding: .day, value: dayOffset, to: evaluatedAt)!
        let date = calendar.date(byAdding: .hour, value: hourOffset, to: day)!
        return ReadinessMetricSample(id: id, value: value, date: date, isReliable: isReliable)
    }
}
