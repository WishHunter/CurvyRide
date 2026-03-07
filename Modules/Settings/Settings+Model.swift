import Factory
import Combine
import Foundation

final class SettingsModel: ObservableObject {
  @Injected(\.settingsRepository) private var settingsRepository
  
  @Published var startPointSummary: String = "Current location"
  
  func load() {
    startPointSummary = settingsRepository.loadPreferredStartPointSummary()
  }
  
  func updateStartPointSummary(_ summary: String) {
    startPointSummary = summary
    settingsRepository.savePreferredStartPointSummary(summary)
  }
}
