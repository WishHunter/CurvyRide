import Factory
import Combine
import CoreLocation
import Foundation
import MapKit
import SwiftUI

@MainActor
final class MapsModel: ObservableObject {
  @Injected(\.plannerSession) private var plannerSession
  private let locationService = CurrentLocationService()

  @Published var routeSummary: String = ""
  @Published var isPlannerSheetPresented = false
  @Published var isPickingStartPoint = false
  @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
  @Published private(set) var mapCenterCoordinate: CLLocationCoordinate2D?

  private var cancellables = Set<AnyCancellable>()

  init() {
    routeSummary = makeRouteSummary(from: plannerSession.settings)
    if let startPoint = plannerSession.settings.startPoint {
      centerOnStartPoint(startPoint)
    }

    plannerSession.$settings
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] settings in
        guard let self else { return }
        self.routeSummary = self.makeRouteSummary(from: settings)
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
    isPlannerSheetPresented = true
  }

  func updateMapCenterCoordinate(_ coordinate: CLLocationCoordinate2D) {
    mapCenterCoordinate = coordinate
  }

  func beginStartPointPicking() -> CLLocationCoordinate2D? {
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
    Task { [weak self] in
      guard let self else { return }

      if let coordinate = await locationService.requestCurrentLocation() {
        let region = MKCoordinateRegion(
          center: coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        await MainActor.run {
          self.cameraPosition = .region(region)
        }
      } else {
        await MainActor.run {
          self.cameraPosition = .userLocation(fallback: .automatic)
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
        displayName: "Pinned on map"
      ),
      shouldRecenter: true
    )

    isPickingStartPoint = false
    isPlannerSheetPresented = true
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
}
