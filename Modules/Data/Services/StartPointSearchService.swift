import Foundation
import MapKit

struct StartPointSearchCompletion: Identifiable {
  let id = UUID()
  let completion: MKLocalSearchCompletion
  let title: String
  let subtitle: String

  var fullText: String {
    if subtitle.isEmpty {
      return title
    }
    return "\(title), \(subtitle)"
  }
}

final class StartPointSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
  @Published var query: String = ""
  @Published var completions: [StartPointSearchCompletion] = []

  private let completer = MKLocalSearchCompleter()

  override init() {
    super.init()
    completer.delegate = self
    completer.resultTypes = [.pointOfInterest, .address]
  }

  func updateQuery(_ value: String) {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      completions = []
      completer.queryFragment = ""
      return
    }

    completer.queryFragment = trimmed
  }

  func clear() {
    query = ""
    completions = []
    completer.queryFragment = ""
  }

  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    completions = completer.results.map {
      StartPointSearchCompletion(
        completion: $0,
        title: $0.title,
        subtitle: $0.subtitle
      )
    }
  }
}
