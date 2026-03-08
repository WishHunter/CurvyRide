import Foundation
import Factory

extension Container {
  var plannerRepository: Factory<PlannerRepositoryProtocol> {
    self { InMemoryPlannerRepository() }.singleton
  }
}

protocol PlannerRepositoryProtocol {
  func loadPreferredStartPointSummary() -> String
  func savePreferredStartPointSummary(_ summary: String)
}

final class InMemoryPlannerRepository: PlannerRepositoryProtocol {
  private var preferredStartPointSummary: String = "Current location"

  func loadPreferredStartPointSummary() -> String {
    preferredStartPointSummary
  }

  func savePreferredStartPointSummary(_ summary: String) {
    preferredStartPointSummary = summary
  }
}
