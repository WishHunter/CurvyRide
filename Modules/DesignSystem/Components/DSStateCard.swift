import SwiftUI

public struct DSStateCard: View {
  public enum Tone {
    case loading
    case empty
    case error
  }

  private let title: String
  private let message: String
  private let tone: Tone
  private let actionTitle: String?
  private let action: (() -> Void)?

  public init(
    title: String,
    message: String,
    tone: Tone = .empty,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.message = message
    self.tone = tone
    self.actionTitle = actionTitle
    self.action = action
  }

  public var body: some View {
    DSSurfaceCard(tone: tone == .error ? .standard : .muted) {
      VStack(alignment: .leading, spacing: 14) {
        HStack(alignment: .center, spacing: 12) {
          indicator

          VStack(alignment: .leading, spacing: 4) {
            Text(title)
              .font(\.title.small)
              .foregroundColor(\.content.primary)

            Text(message)
              .font(\.body.small)
              .foregroundColor(\.content.secondary)
          }
        }

        if let actionTitle, let action {
          DSButton(actionTitle, variant: actionVariant, size: .sm, action: action)
        }
      }
    }
  }

  @ViewBuilder
  private var indicator: some View {
    switch tone {
    case .loading:
      ProgressView()
        .progressViewStyle(.circular)
        .tint(Colors.current.accent.primary.color)
        .frame(width: 22, height: 22)
    case .empty:
      Image(systemName: "circle.dashed")
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(Colors.current.accent.secondary.color)
        .frame(width: 22, height: 22)
    case .error:
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(Colors.current.accent.negative.color)
        .frame(width: 22, height: 22)
    }
  }

  private var actionVariant: DSButton.Variant {
    switch tone {
    case .loading, .empty:
      return .tertiary
    case .error:
      return .destructive
    }
  }
}

#Preview("Empty") {
  DSStateCard(
    title: "No ride start yet",
    message: "Search a place, use your current location, or pin a point on the map."
  )
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Loading") {
  DSStateCard(
    title: "Checking your location",
    message: "Trying to set a sensible ride start for the first launch.",
    tone: .loading
  )
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Error") {
  DSStateCard(
    title: "Current location unavailable",
    message: "We could not access your location right now.",
    tone: .error,
    actionTitle: "Dismiss",
    action: {}
  )
  .padding()
  .background(Colors.current.background.base.color)
}
