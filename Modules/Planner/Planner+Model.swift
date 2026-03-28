import Combine
import Factory
import Foundation
import MapKit

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
  }

  func useCurrentLocation() async {
    guard let coordinate = await locationService.requestCurrentLocation() else { return }
    setStartPoint(
      PlannerStartPoint(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
        displayName: "My current location"
      )
    )
  }

  func searchStartPoint(query: String) async -> PlannerStartPoint? {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty == false else { return nil }

    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = trimmed

    return await resolveStartPoint(request: request, fallbackName: trimmed)
  }

  func searchStartPoint(completion: StartPointSearchCompletion) async -> PlannerStartPoint? {
    let request = MKLocalSearch.Request(completion: completion.completion)
    return await resolveStartPoint(request: request, fallbackName: completion.title)
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
          displayName: "Random Point"
        )
        : nil
    }
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
