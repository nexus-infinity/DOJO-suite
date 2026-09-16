import XCTest
@testable import DOJOShared

final class InteractionContextTests: XCTestCase {
    func testDefaultContextIsConservativeAndDeterministic() {
        let context = InteractionContext()

        XCTAssertEqual(context.inputMode, .text)
        XCTAssertNil(context.preferredOutputMode)
        XCTAssertEqual(context.resolvedOutputMode, .visual)
        XCTAssertEqual(context.biometricState, .unknown)
        XCTAssertEqual(context.environmentState, .unknown)
        XCTAssertEqual(context.activeDevice, .unknown)
    }

    func testContextRoundTripsWithPreferredOutputMode() throws {
        let context = InteractionContext(
            inputMode: .voice,
            preferredOutputMode: .haptic,
            resolvedOutputMode: .haptic,
            biometricState: .stress,
            environmentState: EnvironmentState(noiseLevel: 0.8, isPublic: true, isMotionActive: true),
            activeDevice: .iPhone
        )

        let data = try JSONEncoder().encode(context)
        let decoded = try JSONDecoder().decode(InteractionContext.self, from: data)

        XCTAssertEqual(decoded, context)
    }

    func testPreferredOutputModeCanRemainNil() throws {
        let context = InteractionContext(preferredOutputMode: nil)

        let data = try JSONEncoder().encode(context)
        let decoded = try JSONDecoder().decode(InteractionContext.self, from: data)

        XCTAssertNil(decoded.preferredOutputMode)
    }

    func testDeviceSurfaceRepresentsSeatedAppleSurfacesAndUnknown() {
        XCTAssertTrue(DeviceSurface.allCases.contains(.mac))
        XCTAssertTrue(DeviceSurface.allCases.contains(.iPhone))
        XCTAssertTrue(DeviceSurface.allCases.contains(.watch))
        XCTAssertTrue(DeviceSurface.allCases.contains(.unknown))
    }

    func testInputAndOutputModesAreIndependent() {
        let context = InteractionContext(
            inputMode: .voice,
            preferredOutputMode: .text,
            resolvedOutputMode: .text,
            biometricState: .steady,
            activeDevice: .mac
        )

        XCTAssertEqual(context.inputMode, .voice)
        XCTAssertEqual(context.resolvedOutputMode, .text)
    }

    func testEnvironmentNoiseLevelIsClamped() {
        XCTAssertEqual(EnvironmentState(noiseLevel: -1).noiseLevel, 0)
        XCTAssertEqual(EnvironmentState(noiseLevel: 2).noiseLevel, 1)
    }
}
