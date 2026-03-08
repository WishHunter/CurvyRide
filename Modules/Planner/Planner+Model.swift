import Factory
import Combine
import Foundation

final class PlannerModel: ObservableObject {
  @Injected(\.plannerRepository) private var plannerRepository
  
  @Published var startPointSummary: String = "Current location"
  
  func load() {
    startPointSummary = plannerRepository.loadPreferredStartPointSummary()
  }
  
  func updateStartPointSummary(_ summary: String) {
    startPointSummary = summary
    plannerRepository.savePreferredStartPointSummary(summary)
  }
}
