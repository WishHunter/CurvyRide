import Foundation
import Factory

extension Container {
  var settingsRepository: Factory<SettingsRepositoryProtocol> {
    self { InMemorySettingsRepository() }.singleton
  }
}

protocol SettingsRepositoryProtocol {
  func loadPreferredStartPointSummary() -> String
  func savePreferredStartPointSummary(_ summary: String)
}

final class InMemorySettingsRepository: SettingsRepositoryProtocol {
  private var preferredStartPointSummary: String = "Current location"

  func loadPreferredStartPointSummary() -> String {
    preferredStartPointSummary
  }

  func savePreferredStartPointSummary(_ summary: String) {
    preferredStartPointSummary = summary
  }
}
