import Combine
import Foundation
import Factory

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
  private let locationService = CurrentLocationService()

  @Published var settings: PlannerSettings = .init()
  @Published private(set) var recenterRequest: PlannerRecenterRequest?
  @Published private(set) var startPointBootstrapState: StartPointBootstrapState = .resolving

  init() {
    bootstrapInitialStartPoint()
  }

  func applySettings(_ newSettings: PlannerSettings, recenterOnStartPoint: Bool = false) {
    settings = newSettings

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
