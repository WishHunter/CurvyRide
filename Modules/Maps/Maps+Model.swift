import Factory
import Combine
import Foundation

final class MapsModel: ObservableObject {
  @Injected(\.plannerSession) private var plannerSession

  @Published var startPointSummary: String = "Current location"

  func load() {}
}
