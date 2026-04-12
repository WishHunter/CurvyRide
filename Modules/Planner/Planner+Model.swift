import Combine
import Factory
import Foundation
import MapKit

enum PlannerStartPointFlowState: Equatable {
  case idle
  case locatingCurrentLocation
  case searching(query: String)
  case error(message: String)

  var isBusy: Bool {
    switch self {
    case .locatingCurrentLocation, .searching:
      return true
    case .idle, .error:
      return false
    }
  }
}

@MainActor
final class PlannerModel: ObservableObject {
  @Injected(\.plannerSession) private var plannerSession
  private let locationService = CurrentLocationService()

  private enum Limits {
    static let minDurationMinutes: Int = 10
    static let maxDurationMinutes: Int = 240
    static let defaultDistanceLimitKm: Int = 25
    static let minDistanceLimitKm: Int = 1
    static let maxDistanceLimitKm: Int = 300
  }

  @Published var settings: PlannerSettings = .init()
  @Published private(set) var startPointFlowState: PlannerStartPointFlowState = .idle
  private var cancellables = Set<AnyCancellable>()

  init() {
    settings = plannerSession.settings

    plannerSession.$settings
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newSettings in
        self?.settings = newSettings
      }
      .store(in: &cancellables)
  }

  func update(_ mutate: (inout PlannerSettings) -> Void) {
    var copy = settings
    mutate(&copy)
    normalize(&copy)

    if settings != copy {
      settings = copy
    }
    if plannerSession.settings != copy {
      plannerSession.applySettings(copy)
    }
  }

  func setDuration(_ durationMinutes: Int) {
    update {
      $0.durationMinutes = max(
        Limits.minDurationMinutes,
        min(durationMinutes, Limits.maxDurationMinutes)
      )
    }
  }

  func setDistanceLimit(_ distanceLimitKm: Int?) {
    update {
      guard let distanceLimitKm else {
        $0.distanceLimitKm = nil
        return
      }

      $0.distanceLimitKm = max(
        Limits.minDistanceLimitKm,
        min(distanceLimitKm, Limits.maxDistanceLimitKm)
      )
    }
  }

  func setDistanceLimitEnabled(_ isEnabled: Bool) {
    if isEnabled {
      setDistanceLimit(settings.distanceLimitKm ?? Limits.defaultDistanceLimitKm)
    } else {
      setDistanceLimit(nil)
    }
  }

  func set(_ value: Bool, for keyPath: WritableKeyPath<PlannerSettings, Bool>) {
    update {
      $0[keyPath: keyPath] = value
    }
  }

  func setStartPoint(_ startPoint: PlannerStartPoint?) {
    var copy = settings
    copy.startPoint = startPoint
    normalize(&copy)

    if settings != copy {
      settings = copy
    }
    if plannerSession.settings != copy {
      plannerSession.applySettings(copy, recenterOnStartPoint: startPoint != nil)
    } else if startPoint != nil {
      plannerSession.setStartPoint(startPoint, shouldRecenter: true)
    }
    startPointFlowState = .idle
  }

  func useCurrentLocation() async {
    startPointFlowState = .locatingCurrentLocation

    guard let coordinate = await locationService.requestCurrentLocation() else {
      startPointFlowState = .error(
        message: "We could not access your current location. Search or pin a start instead."
      )
      return
    }

    setStartPoint(
      PlannerStartPoint(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
        displayName: "Current location"
      )
    )
    startPointFlowState = .idle
  }

  func selectStartPoint(query: String) async -> Bool {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty == false else { return false }

    startPointFlowState = .searching(query: trimmed)

    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = trimmed

    guard let startPoint = await resolveStartPoint(request: request, fallbackName: trimmed) else {
      startPointFlowState = .error(
        message: "We could not find '\(trimmed)'. Try another search or pin a start."
      )
      return false
    }

    setStartPoint(startPoint)
    startPointFlowState = .idle
    return true
  }

  func selectStartPoint(completion: StartPointSearchCompletion) async -> Bool {
    startPointFlowState = .searching(query: completion.fullText)
    let request = MKLocalSearch.Request(completion: completion.completion)

    guard let startPoint = await resolveStartPoint(request: request, fallbackName: completion.title) else {
      startPointFlowState = .error(
        message: "We could not use '\(completion.fullText)'. Try another result or pin a start."
      )
      return false
    }

    setStartPoint(startPoint)
    startPointFlowState = .idle
    return true
  }

  private func resolveStartPoint(
    request: MKLocalSearch.Request,
    fallbackName: String
  ) async -> PlannerStartPoint? {

    do {
      let response = try await MKLocalSearch(request: request).start()
      guard let item = response.mapItems.first,
            let coordinate = item.placemark.location?.coordinate else {
        return nil
      }

      return PlannerStartPoint(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
        displayName: item.name ?? fallbackName
      )
    } catch {
      return nil
    }
  }

  func applyRandomSettings() {
    update {
      $0.durationMinutes = Int.random(in: Limits.minDurationMinutes...Limits.maxDurationMinutes)
      $0.distanceLimitKm = Bool.random() ? Int.random(in: Limits.minDistanceLimitKm...Limits.maxDistanceLimitKm) : nil
      $0.isLoopRoute = Bool.random()
      $0.isFastReturn = Bool.random()
      $0.avoidHighways = Bool.random()
      $0.avoidTolls = Bool.random()
      $0.startPoint = Bool.random()
        ? PlannerStartPoint(
          latitude: Double.random(in: 44.70...44.95),
          longitude: Double.random(in: 20.20...20.65),
          displayName: "Random start"
        )
        : nil
    }

    startPointFlowState = .idle
  }

  func clearStartPointFeedback() {
    guard case .error = startPointFlowState else { return }
    startPointFlowState = .idle
  }

  private func normalize(_ settings: inout PlannerSettings) {
    settings.durationMinutes = max(
      Limits.minDurationMinutes,
      min(settings.durationMinutes, Limits.maxDurationMinutes)
    )

    if let distanceLimitKm = settings.distanceLimitKm {
      settings.distanceLimitKm = max(
        Limits.minDistanceLimitKm,
        min(distanceLimitKm, Limits.maxDistanceLimitKm)
      )
    }

    if settings.isLoopRoute == false {
      settings.isFastReturn = false
    }
  }
}
