import CoreLocation
import Foundation

final class CurrentLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private var continuations: [CheckedContinuation<CLLocationCoordinate2D?, Never>] = []
  private var isRequestInFlight = false

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
  }

  func requestCurrentLocation() async -> CLLocationCoordinate2D? {
    return await withCheckedContinuation { continuation in
      continuations.append(continuation)

      if isRequestInFlight {
        return
      }
      isRequestInFlight = true

      startLocationFlow()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    resumeAll(with: locations.first?.coordinate)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    resumeAll(with: nil)
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard isRequestInFlight else { return }

    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      manager.requestLocation()
    case .denied, .restricted:
      resumeAll(with: nil)
    case .notDetermined:
      break
    @unknown default:
      resumeAll(with: nil)
    }
  }

  private func startLocationFlow() {
    switch locationManager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      locationManager.requestLocation()
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .denied, .restricted:
      resumeAll(with: nil)
    @unknown default:
      resumeAll(with: nil)
    }
  }

  private func resumeAll(with coordinate: CLLocationCoordinate2D?) {
    let pending = continuations
    continuations.removeAll()
    isRequestInFlight = false
    pending.forEach { $0.resume(returning: coordinate) }
  }
}
