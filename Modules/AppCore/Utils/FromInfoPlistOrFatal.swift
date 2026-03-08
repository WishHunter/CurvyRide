import Foundation

public func fromInfoPlistOrFatal(key: String) -> String {
  guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
    bug("No value in InfoPlist for key: \(key) provided")
    return ""
  }
  return value
}
