import Combine
import Foundation
import Factory

extension Container {
  var plannerSession: Factory<PlannerSession> {
    self { PlannerSession() }.singleton
  }
}

final class PlannerSession: ObservableObject {
  private let locationService = CurrentLocationService()

  @Published var settings: PlannerSettings = .init()
  @Published private(set) var recenterRequest: PlannerRecenterRequest?

  init() {
    bootstrapInitialStartPoint()
  }

  func applySettings(_ newSettings: PlannerSettings, recenterOnStartPoint: Bool = false) {
    settings = newSettings

    guard recenterOnStartPoint, let startPoint = newSettings.startPoint else { return }
    recenterRequest = PlannerRecenterRequest(startPoint: startPoint)
  }

  func setStartPoint(_ startPoint: PlannerStartPoint?, shouldRecenter: Bool = false) {
    var copy = settings
    copy.startPoint = startPoint
    applySettings(copy, recenterOnStartPoint: shouldRecenter)
  }

  private func bootstrapInitialStartPoint() {
    Task { [weak self] in
      guard let self else { return }
      guard let coordinate = await locationService.requestCurrentLocation() else { return }

      await MainActor.run {
        guard self.settings.startPoint == nil else { return }
        self.setStartPoint(
          PlannerStartPoint(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            displayName: "My current location"
          ),
          shouldRecenter: true
        )
      }
    }
  }
}

struct PlannerSettings: Equatable {
  var durationMinutes: Int = 60
  var distanceLimitKm: Int? = nil
  var isLoopRoute: Bool = false
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
