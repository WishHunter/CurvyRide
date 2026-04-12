import SwiftUI

public struct DSSurfaceCard<Content: View>: View {
  public enum Tone {
    case standard
    case muted
  }

  private let tone: Tone
  private let content: Content

  public init(
    tone: Tone = .standard,
    @ViewBuilder content: () -> Content
  ) {
    self.tone = tone
    self.content = content()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      content
    }
    .padding(16)
    .background {
      RoundedRectangle(cornerRadius: Radii.current.large, style: .continuous)
        .fill(backgroundColor)
    }
    .overlay {
      RoundedRectangle(cornerRadius: Radii.current.large, style: .continuous)
        .strokeBorder(Colors.current.stroke.soft.color, lineWidth: 1)
    }
    .shadow(\.soft)
  }

  private var backgroundColor: Color {
    switch tone {
    case .standard:
      return Colors.current.background.surface.color
    case .muted:
      return Colors.current.background.neutral.color
    }
  }
}

#Preview {
  VStack(spacing: 16) {
    DSSurfaceCard {
      Text("Standard Surface")
        .font(\.title.small)
        .foregroundColor(\.content.primary)
      Text("Primary shell for grouped controls and content.")
        .font(\.body.small)
        .foregroundColor(\.content.secondary)
    }

    DSSurfaceCard(tone: .muted) {
      Text("Muted Surface")
        .font(\.title.small)
        .foregroundColor(\.content.primary)
      Text("Softer grouping for nested UI.")
        .font(\.body.small)
        .foregroundColor(\.content.secondary)
    }
  }
  .padding(24)
  .background(Colors.current.background.base.color)
}
