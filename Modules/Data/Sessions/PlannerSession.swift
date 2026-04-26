import Combine
import Factory
import Foundation

extension Container {
  var plannerSession: Factory<PlannerSession> {
    self { PlannerSession() }.singleton
  }
}

enum StartPointBootstrapState: Equatable {
  case resolving
  case ready
  case unavailable
}

final class PlannerSession: ObservableObject {
  private let userDefaultsStore: UserDefaultsStore
  private let locationService: CurrentLocationService
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  private enum StorageKeys {
    static let plannerDefaults = "planner.defaults"
  }

  private struct StoredPlannerDefaults: Codable {
    var durationMinutes: Int
    var distanceLimitKm: Int?
    var isLoopRoute: Bool
    var isFastReturn: Bool
    var avoidHighways: Bool
    var avoidTolls: Bool

    init(settings: PlannerSettings) {
      durationMinutes = settings.durationMinutes
      distanceLimitKm = settings.distanceLimitKm
      isLoopRoute = settings.isLoopRoute
      isFastReturn = settings.isFastReturn
      avoidHighways = settings.avoidHighways
      avoidTolls = settings.avoidTolls
    }

    func makeSettings() -> PlannerSettings {
      PlannerSettings(
        durationMinutes: durationMinutes,
        distanceLimitKm: distanceLimitKm,
        isLoopRoute: isLoopRoute,
        isFastReturn: isFastReturn,
        avoidHighways: avoidHighways,
        avoidTolls: avoidTolls
      )
    }
  }

  @Published var settings: PlannerSettings = .init()
  @Published private(set) var recenterRequest: PlannerRecenterRequest?
  @Published private(set) var startPointBootstrapState: StartPointBootstrapState = .resolving

  init(
    userDefaultsStore: UserDefaultsStore,
    locationService: CurrentLocationService,
    shouldBootstrapStartPoint: Bool
  ) {
    self.userDefaultsStore = userDefaultsStore
    self.locationService = locationService
    settings = loadStoredDefaults()

    if shouldBootstrapStartPoint {
      bootstrapInitialStartPoint()
    } else {
      startPointBootstrapState = settings.startPoint == nil ? .unavailable : .ready
    }
  }

  convenience init() {
    self.init(
      userDefaultsStore: Container.shared.userDefaultsStore(),
      locationService: CurrentLocationService(),
      shouldBootstrapStartPoint: true
    )
  }

  func applySettings(_ newSettings: PlannerSettings, recenterOnStartPoint: Bool = false) {
    settings = newSettings
    saveStoredDefaults(from: newSettings)

    if newSettings.startPoint != nil {
      startPointBootstrapState = .ready
    }

    guard recenterOnStartPoint, let startPoint = newSettings.startPoint else { return }
    recenterRequest = PlannerRecenterRequest(startPoint: startPoint)
  }

  func setStartPoint(_ startPoint: PlannerStartPoint?, shouldRecenter: Bool = false) {
    var copy = settings
    copy.startPoint = startPoint
    applySettings(copy, recenterOnStartPoint: shouldRecenter)
  }

  private func bootstrapInitialStartPoint() {
    guard settings.startPoint == nil else {
      startPointBootstrapState = .ready
      return
    }

    startPointBootstrapState = .resolving

    Task { [weak self] in
      guard let self else { return }
      guard let coordinate = await locationService.requestCurrentLocation() else {
        await MainActor.run {
          self.startPointBootstrapState = self.settings.startPoint == nil ? .unavailable : .ready
        }
        return
      }

      await MainActor.run {
        guard self.settings.startPoint == nil else {
          self.startPointBootstrapState = .ready
          return
        }

        self.setStartPoint(
          PlannerStartPoint(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            displayName: "Current location"
          ),
          shouldRecenter: true
        )
        self.startPointBootstrapState = .ready
      }
    }
  }

  private func loadStoredDefaults() -> PlannerSettings {
    guard let data = userDefaultsStore.data(forKey: StorageKeys.plannerDefaults) else {
      return .init()
    }

    do {
      let storedDefaults = try decoder.decode(StoredPlannerDefaults.self, from: data)
      return storedDefaults.makeSettings()
    } catch {
      userDefaultsStore.removeValue(forKey: StorageKeys.plannerDefaults)
      return .init()
    }
  }

  private func saveStoredDefaults(from settings: PlannerSettings) {
    do {
      let storedDefaults = StoredPlannerDefaults(settings: settings)
      let data = try encoder.encode(storedDefaults)
      userDefaultsStore.set(data, forKey: StorageKeys.plannerDefaults)
    } catch {
      userDefaultsStore.removeValue(forKey: StorageKeys.plannerDefaults)
    }
  }
}

struct PlannerSettings: Equatable {
  var durationMinutes: Int = 60
  var distanceLimitKm: Int? = nil
  var isLoopRoute: Bool = true
  var isFastReturn: Bool = false
  var avoidHighways: Bool = false
  var avoidTolls: Bool = false
  var startPoint: PlannerStartPoint? = nil
}

struct PlannerStartPoint: Equatable {
  var latitude: Double
  var longitude: Double
  var displayName: String?
}

struct PlannerRecenterRequest: Equatable {
  let id = UUID()
  let startPoint: PlannerStartPoint
}
