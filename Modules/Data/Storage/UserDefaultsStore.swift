import Factory
import Foundation

final class UserDefaultsStore {
  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func data(forKey key: String) -> Data? {
    defaults.data(forKey: key)
  }

  func set(_ data: Data, forKey key: String) {
    defaults.set(data, forKey: key)
  }

  func removeValue(forKey key: String) {
    defaults.removeObject(forKey: key)
  }
}

extension Container {
  var userDefaultsStore: Factory<UserDefaultsStore> {
    self { UserDefaultsStore() }.singleton
  }
}
