import Factory
import Combine
import CoreLocation
import Foundation
import MapKit
import SwiftUI

struct MapsSummaryTag: Identifiable, Equatable {
  enum Tone: Equatable {
    case neutral
    case accent
  }

  let title: String
  let tone: Tone

  var id: String {
    "\(title)-\(tone == .accent ? "accent" : "neutral")"
  }
}

enum MapsScreenState: Equatable {
  case loading
  case empty
  case ready
  case error(String)
}

@MainActor
final class MapsModel: ObservableObject {
  @Injected(\.plannerSession) private var plannerSession
  private let locationService = CurrentLocationService()

  @Published var routeSummary: String = ""
  @Published var isPlannerSheetPresented = false
  @Published var isPickingStartPoint = false
  @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
  @Published private(set) var mapCenterCoordinate: CLLocationCoordinate2D?
  @Published private(set) var summaryTitle: String = "Set Start"
  @Published private(set) var statusTitle: String = "Set Start"
  @Published private(set) var summaryTags: [MapsSummaryTag] = []
  @Published private(set) var screenState: MapsScreenState = .loading

  private var cancellables = Set<AnyCancellable>()
  private var currentSettings: PlannerSettings = .init()
  private var startPointBootstrapState: StartPointBootstrapState = .resolving
  private var screenErrorMessage: String?

  init() {
    let initialSettings = plannerSession.settings
    currentSettings = initialSettings
    startPointBootstrapState = plannerSession.startPointBootstrapState
    routeSummary = makeRouteSummary(from: initialSettings)
    updatePresentation(from: initialSettings)
    recomputeScreenState()

    if let startPoint = initialSettings.startPoint {
      centerOnStartPoint(startPoint)
    }

    plannerSession.$settings
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] settings in
        guard let self else { return }
        self.currentSettings = settings
        if settings.startPoint != nil {
          self.screenErrorMessage = nil
        }
        self.routeSummary = self.makeRouteSummary(from: settings)
        self.updatePresentation(from: settings)
        self.recomputeScreenState()
      }
      .store(in: &cancellables)

    plannerSession.$startPointBootstrapState
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] bootstrapState in
        self?.startPointBootstrapState = bootstrapState
        self?.recomputeScreenState()
      }
      .store(in: &cancellables)

    plannerSession.$recenterRequest
      .compactMap { $0?.startPoint }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] startPoint in
        self?.centerOnStartPoint(startPoint)
      }
      .store(in: &cancellables)
  }

  func presentPlannerSheet() {
    clearScreenError()
    isPlannerSheetPresented = true
  }

  func updateMapCenterCoordinate(_ coordinate: CLLocationCoordinate2D) {
    mapCenterCoordinate = coordinate
  }

  func beginStartPointPicking() -> CLLocationCoordinate2D? {
    clearScreenError()
    isPlannerSheetPresented = false
    isPickingStartPoint = true

    guard let startPoint = plannerSession.settings.startPoint else {
      return nil
    }

    let coordinate = CLLocationCoordinate2D(
      latitude: startPoint.latitude,
      longitude: startPoint.longitude
    )
    mapCenterCoordinate = coordinate
    return coordinate
  }

  func showMe() {
    clearScreenError()

    Task { [weak self] in
      guard let self else { return }

      if let coordinate = await locationService.requestCurrentLocation() {
        let region = MKCoordinateRegion(
          center: coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        await MainActor.run {
          self.cameraPosition = .region(region)
          self.clearScreenError()
        }
      } else {
        await MainActor.run {
          self.cameraPosition = .userLocation(fallback: .automatic)
          self.screenErrorMessage = "We could not access your current location. You can still set the start manually."
          self.recomputeScreenState()
        }
      }
    }
  }

  private func centerOnStartPoint(_ startPoint: PlannerStartPoint) {
    let center = CLLocationCoordinate2D(latitude: startPoint.latitude, longitude: startPoint.longitude)
    cameraPosition = .region(
      MKCoordinateRegion(
        center: center,
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      )
    )
  }

  func cancelStartPointPicking() {
    isPickingStartPoint = false
    isPlannerSheetPresented = true
  }

  func applyStartPointPicking() {
    guard let mapCenterCoordinate else { return }

    plannerSession.setStartPoint(
      PlannerStartPoint(
        latitude: mapCenterCoordinate.latitude,
        longitude: mapCenterCoordinate.longitude,
        displayName: "Pinned start"
      ),
      shouldRecenter: true
    )

    isPickingStartPoint = false
    isPlannerSheetPresented = true
  }

  func clearScreenError() {
    screenErrorMessage = nil
    recomputeScreenState()
  }

  private func makeRouteSummary(from settings: PlannerSettings) -> String {
    var parts: [String] = ["\(settings.durationMinutes) min"]

    if let startPoint = settings.startPoint {
      if let displayName = startPoint.displayName, displayName.isEmpty == false {
        parts.append(displayName)
      } else {
        parts.append(String(format: "%.4f, %.4f", startPoint.latitude, startPoint.longitude))
      }
    } else {
      parts.append("No start point")
    }

    if let distanceLimitKm = settings.distanceLimitKm {
      parts.append("Max \(distanceLimitKm) km")
    }

    return parts.joined(separator: " • ")
  }

  private func updatePresentation(from settings: PlannerSettings) {
    summaryTitle = startPointTitle(from: settings.startPoint)
    summaryTags = makeSummaryTags(from: settings)
    updateStatusTitle(using: settings)
  }

  private func updateStatusTitle(using settings: PlannerSettings) {
    switch screenState {
    case .loading:
      statusTitle = "Preparing"
    case .empty:
      statusTitle = "Set Start"
    case .ready:
      statusTitle = settings.isLoopRoute ? "Loop" : "Point-to-Point"
    case .error:
      statusTitle = "Location"
    }
  }

  private func startPointTitle(from startPoint: PlannerStartPoint?) -> String {
    guard let startPoint else { return "Set Start" }
    guard let displayName = startPoint.displayName, displayName.isEmpty == false else {
      return String(format: "%.4f, %.4f", startPoint.latitude, startPoint.longitude)
    }
    return displayName
  }

  private func makeSummaryTags(from settings: PlannerSettings) -> [MapsSummaryTag] {
    var tags: [MapsSummaryTag] = [
      MapsSummaryTag(title: "\(settings.durationMinutes) min", tone: .neutral),
      MapsSummaryTag(
        title: settings.isLoopRoute ? "Loop" : "Point-to-Point",
        tone: .accent
      )
    ]

    if let distanceLimitKm = settings.distanceLimitKm {
      tags.append(MapsSummaryTag(title: "\(distanceLimitKm) km max", tone: .neutral))
    }

    if settings.isFastReturn {
      tags.append(MapsSummaryTag(title: "Fast Return", tone: .accent))
    }

    tags.append(MapsSummaryTag(title: roadPreferenceTitle(from: settings), tone: .neutral))
    return tags
  }

  private func roadPreferenceTitle(from settings: PlannerSettings) -> String {
    if settings.avoidTolls {
      return "No Tolls"
    }
    if settings.avoidHighways {
      return "No Highways"
    }
    return "Road Mix"
  }

  private func recomputeScreenState() {
    if let screenErrorMessage {
      screenState = .error(screenErrorMessage)
    } else if currentSettings.startPoint != nil {
      screenState = .ready
    } else {
      switch startPointBootstrapState {
      case .resolving:
        screenState = .loading
      case .ready, .unavailable:
        screenState = .empty
      }
    }

    updateStatusTitle(using: currentSettings)
  }
}
