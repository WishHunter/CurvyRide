import Combine
import Foundation
import Factory

extension Container {
  var plannerSession: Factory<PlannerSession> {
    self { PlannerSession() }.singleton
  }
}

final class PlannerSession: ObservableObject {
  @Published var startPointSummary: String = "Current location"
}
