import SwiftUI
import UIKit

public typealias DSColor = KeyPath<Colors, UIColor>

public extension DSColor {
  var uiColor: UIColor {
    Colors.current[keyPath: self]
  }
}

public struct Colors {
  public static var current = Colors()

  public let content = Content()
  public let background = Background()
  public let accent = Accent()

  public init() {}

  public struct Content {
    public let primary = UIColor(light: 0x141414, dark: 0xF5F5F5)
    public let secondary = UIColor(light: 0x141414, lAlpha: 0.60, dark: 0xF5F5F5, dAlpha: 0.60)
    public let tertiary = UIColor(light: 0x141414, lAlpha: 0.20, dark: 0xF5F5F5, dAlpha: 0.20)

    public init() {}
  }

  public struct Background {
    public let base = UIColor(light: 0xFFFFFF, dark: 0x111111)
    public let positive = UIColor(light: 0x34C759, lAlpha: 0.16, dark: 0x30D158, dAlpha: 0.22)
    public let negative = UIColor(light: 0xFF3B30, lAlpha: 0.16, dark: 0xFF453A, dAlpha: 0.22)
    public let neutral = UIColor(light: 0x8E8E93, lAlpha: 0.16, dark: 0x8E8E93, dAlpha: 0.24)

    public init() {}
  }

  public struct Accent {
    public let primary = UIColor(light: 0x0A84FF, dark: 0x0A84FF)
    public let secondary = UIColor(light: 0x5E5CE6, dark: 0x5E5CE6)
    public let positive = UIColor(light: 0x34C759, lAlpha: 0.80, dark: 0x30D158, dAlpha: 0.80)
    public let negative = UIColor(light: 0xFF3B30, lAlpha: 0.80, dark: 0xFF453A, dAlpha: 0.80)
    public let links = UIColor(light: 0x007AFF, dark: 0x0A84FF)

    public init() {}
  }
}

public struct ColoredString: Equatable {
  public let value: String
  public let color: Color

  public init(value: String, color: Color) {
    self.value = value
    self.color = color
  }

  public static let empty = ColoredString(
    value: "",
    color: Colors.current.content.primary.color
  )
}

#Preview {
  func block(name: String, color: Color) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(name)
        .font(\.headline.medium14)
        .foregroundColor(\.content.primary)
      RoundedRectangle(cornerRadius: 8)
        .frame(width: 100, height: 50)
        .foregroundColor(color)
    }
  }

  return ZStack {
    Color.gray.opacity(0.2)
      .ignoresSafeArea()

    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 8) {
        block(name: "Content Primary", color: Colors.current.content.primary.color)
        block(name: "Content Secondary", color: Colors.current.content.secondary.color)
        block(name: "Content Tertiary", color: Colors.current.content.tertiary.color)

        Spacer().frame(height: 40)

        block(name: "Background Base", color: Colors.current.background.base.color)
        block(name: "Background Positive", color: Colors.current.background.positive.color)
        block(name: "Background Negative", color: Colors.current.background.negative.color)
        block(name: "Background Neutral", color: Colors.current.background.neutral.color)
      }
      Spacer()

      VStack(alignment: .leading, spacing: 8) {
        block(name: "Accent Primary", color: Colors.current.accent.primary.color)
        block(name: "Accent Secondary", color: Colors.current.accent.secondary.color)
        block(name: "Accent Positive", color: Colors.current.accent.positive.color)
        block(name: "Accent Negative", color: Colors.current.accent.negative.color)
        block(name: "Accent Links", color: Colors.current.accent.links.color)
      }
    }
    .padding(.horizontal, 16)
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
}
