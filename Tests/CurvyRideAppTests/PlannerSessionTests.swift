import Foundation
import XCTest
@testable import CurvyRideApp

@MainActor
final class PlannerSessionTests: XCTestCase {
  func testUsesDefaultSettingsWhenStorageIsEmpty() {
    let defaults = makeDefaults()

    let session = makeSession(defaults: defaults)

    XCTAssertEqual(session.settings.durationMinutes, 60)
    XCTAssertNil(session.settings.distanceLimitKm)
    XCTAssertTrue(session.settings.isLoopRoute)
    XCTAssertFalse(session.settings.isFastReturn)
    XCTAssertFalse(session.settings.avoidHighways)
    XCTAssertFalse(session.settings.avoidTolls)
    XCTAssertNil(session.settings.startPoint)
  }

  func testFallsBackToDefaultsWhenStoredPayloadIsCorrupt() {
    let defaults = makeDefaults()
    defaults.set(Data([0xFF, 0x00, 0x7A]), forKey: "planner.defaults")

    let session = makeSession(defaults: defaults)

    XCTAssertEqual(session.settings, PlannerSettings())
    XCTAssertNil(defaults.data(forKey: "planner.defaults"))
  }

  func testPersistsAndRestoresPlannerDefaultsOnly() {
    let defaults = makeDefaults()
    let session = makeSession(defaults: defaults)

    session.applySettings(
      PlannerSettings(
        durationMinutes: 95,
        distanceLimitKm: 180,
        isLoopRoute: false,
        isFastReturn: false,
        avoidHighways: true,
        avoidTolls: true,
        startPoint: PlannerStartPoint(
          latitude: 44.8125,
          longitude: 20.4612,
          displayName: "Belgrade"
        )
      )
    )

    let restoredSession = makeSession(defaults: defaults)

    XCTAssertEqual(restoredSession.settings.durationMinutes, 95)
    XCTAssertEqual(restoredSession.settings.distanceLimitKm, 180)
    XCTAssertFalse(restoredSession.settings.isLoopRoute)
    XCTAssertFalse(restoredSession.settings.isFastReturn)
    XCTAssertTrue(restoredSession.settings.avoidHighways)
    XCTAssertTrue(restoredSession.settings.avoidTolls)
    XCTAssertNil(restoredSession.settings.startPoint)
  }

  private func makeSession(defaults: UserDefaults) -> PlannerSession {
    PlannerSession(
      userDefaultsStore: UserDefaultsStore(defaults: defaults),
      locationService: CurrentLocationService(),
      shouldBootstrapStartPoint: false
    )
  }

  private func makeDefaults() -> UserDefaults {
    let suiteName = "PlannerSessionTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
  }
}
