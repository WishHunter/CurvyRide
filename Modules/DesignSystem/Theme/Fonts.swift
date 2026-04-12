import SwiftUI
import UIKit

public typealias DSFont = KeyPath<Fonts, Font>

public extension DSFont {
  var font: Font {
    Fonts.current[keyPath: self]
  }
}

public struct Fonts {
  public static var current = Fonts()

  public let display = Display()
  public let title = Title()
  public let body = Body()
  public let label = Label()
  public let metric = Metric()

  // Backward-compatible aliases for the current codebase.
  public let heading = Heading()
  public let headline = Headline()

  public init() {}

  public struct Display {
    public let hero: Font = .system(size: 40, weight: .semibold)
    public let large: Font = .system(size: 32, weight: .semibold)
  }

  public struct Title {
    public let large: Font = .system(size: 28, weight: .semibold)
    public let medium: Font = .system(size: 22, weight: .semibold)
    public let small: Font = .system(size: 18, weight: .semibold)
  }

  public struct Body {
    public let large: Font = .system(size: 16, weight: .regular)
    public let medium: Font = .system(size: 14, weight: .regular)
    public let small: Font = .system(size: 12, weight: .regular)

    // Compatibility aliases.
    public let large16: Font = .system(size: 16, weight: .regular)
    public let medium14: Font = .system(size: 14, weight: .regular)
    public let small12: Font = .system(size: 12, weight: .regular)
  }

  public struct Label {
    public let large: Font = .system(size: 16, weight: .semibold)
    public let medium: Font = .system(size: 14, weight: .semibold)
    public let small: Font = .system(size: 12, weight: .semibold)
  }

  public struct Metric {
    public let large: Font = .system(size: 34, weight: .semibold, design: .monospaced)
    public let medium: Font = .system(size: 20, weight: .semibold, design: .monospaced)
    public let small: Font = .system(size: 14, weight: .semibold, design: .monospaced)
  }

  public struct Heading {
    public let h1: Font = .system(size: 40, weight: .semibold)
    public let h2: Font = .system(size: 32, weight: .semibold)
    public let h3: Font = .system(size: 28, weight: .semibold)
    public let h4: Font = .system(size: 22, weight: .semibold)
    public let h5: Font = .system(size: 18, weight: .semibold)
  }

  public struct Headline {
    public let large16: Font = .system(size: 16, weight: .semibold)
    public let medium14: Font = .system(size: 14, weight: .semibold)
  }
}

public extension DSFont {
  var uiFont: UIFont {
    switch self {
    case \.display.hero, \.heading.h1:
      return .systemFont(ofSize: 40, weight: .semibold)
    case \.display.large, \.heading.h2:
      return .systemFont(ofSize: 32, weight: .semibold)
    case \.title.large, \.heading.h3:
      return .systemFont(ofSize: 28, weight: .semibold)
    case \.title.medium, \.heading.h4:
      return .systemFont(ofSize: 22, weight: .semibold)
    case \.title.small, \.heading.h5:
      return .systemFont(ofSize: 18, weight: .semibold)
    case \.body.large, \.body.large16:
      return .systemFont(ofSize: 16, weight: .regular)
    case \.body.medium, \.body.medium14:
      return .systemFont(ofSize: 14, weight: .regular)
    case \.body.small, \.body.small12:
      return .systemFont(ofSize: 12, weight: .regular)
    case \.label.large, \.headline.large16:
      return .systemFont(ofSize: 16, weight: .semibold)
    case \.label.medium, \.headline.medium14:
      return .systemFont(ofSize: 14, weight: .semibold)
    case \.label.small:
      return .systemFont(ofSize: 12, weight: .semibold)
    case \.metric.large:
      return .monospacedSystemFont(ofSize: 34, weight: .semibold)
    case \.metric.medium:
      return .monospacedSystemFont(ofSize: 20, weight: .semibold)
    case \.metric.small:
      return .monospacedSystemFont(ofSize: 14, weight: .semibold)
    default:
      return .systemFont(ofSize: 14, weight: .regular)
    }
  }
}

#Preview {
  func block(name: String, font: DSFont) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(name)
        .font(\.label.small)
        .foregroundColor(\.content.secondary)
      Text("CurvyRide 128 km")
        .font(font)
        .foregroundColor(\.content.primary)
    }
  }

  return VStack(alignment: .leading, spacing: 18) {
    block(name: "Display / Hero", font: \.display.hero)
    block(name: "Display / Large", font: \.display.large)
    block(name: "Title / Large", font: \.title.large)
    block(name: "Title / Medium", font: \.title.medium)
    block(name: "Body / Large", font: \.body.large)
    block(name: "Label / Medium", font: \.label.medium)
    block(name: "Metric / Large", font: \.metric.large)
  }
  .padding(24)
  .background(Colors.current.background.base.color)
}
