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

  public let heading = Heading()
  public let headline = Headline()
  public let body = Body()

  public struct Heading {
    public let h1: Font = .system(size: 40, weight: .semibold)
    public let h2: Font = .system(size: 32, weight: .semibold)
    public let h3: Font = .system(size: 28, weight: .semibold)
    public let h4: Font = .system(size: 24, weight: .semibold)
    public let h5: Font = .system(size: 20, weight: .semibold)
  }

  public struct Headline {
    public let large16: Font = .system(size: 16, weight: .semibold)
    public let medium14: Font = .system(size: 14, weight: .semibold)
  }

  public struct Body {
    public let large16: Font = .system(size: 16, weight: .regular)
    public let medium14: Font = .system(size: 14, weight: .regular)
    public let small12: Font = .system(size: 12, weight: .regular)
  }
}

public extension DSFont {
  var uiFont: UIFont {
    switch self {
    case \.body.small12:
      return .systemFont(ofSize: 12, weight: .regular)
    case \.body.medium14:
      return .systemFont(ofSize: 14, weight: .regular)
    case \.body.large16:
      return .systemFont(ofSize: 16, weight: .regular)
    case \.headline.medium14:
      return .systemFont(ofSize: 14, weight: .semibold)
    case \.headline.large16:
      return .systemFont(ofSize: 16, weight: .semibold)
    case \.heading.h5:
      return .systemFont(ofSize: 20, weight: .semibold)
    case \.heading.h4:
      return .systemFont(ofSize: 24, weight: .semibold)
    case \.heading.h3:
      return .systemFont(ofSize: 28, weight: .semibold)
    case \.heading.h2:
      return .systemFont(ofSize: 32, weight: .semibold)
    case \.heading.h1:
      return .systemFont(ofSize: 40, weight: .semibold)
    default:
      return .systemFont(ofSize: 14, weight: .regular)
    }
  }
}

#Preview {
  func block(name: String, font: DSFont) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(name)
        .font(font)
        .foregroundColor(\.content.primary)
    }
  }

  return HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 14) {
        block(name: "Heading H1", font: \.heading.h1)
        block(name: "Heading H2", font: \.heading.h2)
        block(name: "Heading H3", font: \.heading.h3)
        block(name: "Heading H4", font: \.heading.h4)
        block(name: "Heading H5", font: \.heading.h5)

        Spacer().frame(height: 40)

        block(name: "Headline Large16", font: \.headline.large16)
        block(name: "Headline Medium14", font: \.headline.medium14)

        Spacer().frame(height: 40)

        block(name: "Body Large16", font: \.body.large16)
        block(name: "Body Medium14", font: \.body.medium14)
        block(name: "Body Small12", font: \.body.small12)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 20)
}
