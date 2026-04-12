import SwiftUI

public struct DSChip: View {
  public enum Tone {
    case neutral
    case accent
  }

  private let title: String
  private let tone: Tone

  public init(
    _ title: String,
    tone: Tone = .neutral
  ) {
    self.title = title
    self.tone = tone
  }

  public var body: some View {
    let appearance = self.appearance

    Text(title)
      .font(\.label.small)
      .foregroundColor(appearance.foregroundColor)
      .lineLimit(1)
      .fixedSize(horizontal: true, vertical: false)
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background {
        Capsule(style: .continuous)
          .fill(appearance.backgroundColor)
      }
      .overlay {
        if let borderColor = appearance.borderColor {
          Capsule(style: .continuous)
            .strokeBorder(borderColor, lineWidth: 1)
        }
      }
  }

  private var appearance: Appearance {
    switch tone {
    case .neutral:
      return Appearance(
        foregroundColor: Colors.current.content.primary.color,
        backgroundColor: Colors.current.background.neutral.color,
        borderColor: nil
      )
    case .accent:
      return Appearance(
        foregroundColor: Colors.current.accent.secondary.color,
        backgroundColor: Colors.current.accent.primary.color.opacity(0.14),
        borderColor: Colors.current.stroke.accent.color
      )
    }
  }

  private struct Appearance {
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color?
  }
}

#Preview {
  HStack(spacing: 12) {
    DSChip("90 min")
    DSChip("Loop", tone: .accent)
    DSChip("No tolls")
  }
  .padding(24)
  .background(Colors.current.background.base.color)
}
