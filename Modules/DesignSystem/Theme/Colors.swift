import SwiftUI
import UIKit

public typealias DSColor = KeyPath<Colors, UIColor>

public extension DSColor {
  var uiColor: UIColor {
    Colors.current[keyPath: self]
  }

  var color: Color {
    uiColor.color
  }
}

public struct Colors {
  public static var current = Colors()

  public let content = Content()
  public let background = Background()
  public let accent = Accent()
  public let stroke = Stroke()

  public init() {}

  public struct Content {
    public let primary = UIColor(light: 0x1E1E1A, dark: 0xF2ECE4)
    public let secondary = UIColor(light: 0x6F6C66, dark: 0xB1A79A)
    public let tertiary = UIColor(light: 0x948B82, dark: 0x8C8277)
    public let disabled = UIColor(light: 0xB7AFA6, dark: 0x62584F)
    public let inverse = UIColor(light: 0xFBFAF7, dark: 0x1E1E1A)
    public let onAccent = UIColor(light: 0x1E1E1A, dark: 0x1E1E1A)

    public init() {}
  }

  public struct Background {
    public let base = UIColor(light: 0xF3F1EE, dark: 0x15120F)
    public let surface = UIColor(light: 0xFBFAF7, lAlpha: 0.94, dark: 0x211C18, dAlpha: 0.94)
    public let elevated = UIColor(light: 0xE9E2D9, lAlpha: 0.96, dark: 0x2B241E, dAlpha: 0.96)
    public let neutral = UIColor(light: 0xF1EBE3, lAlpha: 0.92, dark: 0x2F2822, dAlpha: 0.92)
    public let strong = UIColor(light: 0x2B2520, dark: 0xF2ECE4)
    public let disabled = UIColor(light: 0xE6DED4, lAlpha: 0.72, dark: 0x2A241E, dAlpha: 0.72)
    public let positive = UIColor(light: 0x2F9E66, lAlpha: 0.16, dark: 0x4CB67D, dAlpha: 0.24)
    public let negative = UIColor(light: 0xC85C4E, lAlpha: 0.16, dark: 0xE47B6D, dAlpha: 0.24)

    public init() {}
  }

  public struct Accent {
    public let primary = UIColor(light: 0xC58A4A, dark: 0xD39B5A)
    public let secondary = UIColor(light: 0xA56E36, dark: 0xB57D3E)
    public let positive = UIColor(light: 0x2F9E66, dark: 0x4CB67D)
    public let negative = UIColor(light: 0xC85C4E, dark: 0xE47B6D)
    public let links = UIColor(light: 0xA56E36, dark: 0xD39B5A)

    public init() {}
  }

  public struct Stroke {
    public let soft = UIColor(light: 0xE6DED4, dark: 0x302821)
    public let strong = UIColor(light: 0xD5CCC1, dark: 0x4A4138)
    public let accent = UIColor(light: 0xC58A4A, lAlpha: 0.34, dark: 0xD39B5A, dAlpha: 0.38)
    public let negative = UIColor(light: 0xC85C4E, lAlpha: 0.28, dark: 0xE47B6D, dAlpha: 0.36)

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
    VStack(alignment: .leading, spacing: 6) {
      Text(name)
        .font(\.label.medium)
        .foregroundColor(\.content.primary)
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .frame(width: 112, height: 56)
        .foregroundColor(color)
    }
  }

  return ZStack {
    Colors.current.background.base.color
      .ignoresSafeArea()

    HStack(alignment: .top, spacing: 28) {
      VStack(alignment: .leading, spacing: 12) {
        block(name: "Content / Primary", color: Colors.current.content.primary.color)
        block(name: "Content / Secondary", color: Colors.current.content.secondary.color)
        block(name: "Content / Inverse", color: Colors.current.content.inverse.color)
        block(name: "Background / Base", color: Colors.current.background.base.color)
        block(name: "Background / Surface", color: Colors.current.background.surface.color)
        block(name: "Background / Strong", color: Colors.current.background.strong.color)
      }

      VStack(alignment: .leading, spacing: 12) {
        block(name: "Accent / Primary", color: Colors.current.accent.primary.color)
        block(name: "Accent / Secondary", color: Colors.current.accent.secondary.color)
        block(name: "Stroke / Soft", color: Colors.current.stroke.soft.color)
        block(name: "Stroke / Strong", color: Colors.current.stroke.strong.color)
        block(name: "State / Positive", color: Colors.current.background.positive.color)
        block(name: "State / Negative", color: Colors.current.background.negative.color)
      }
    }
    .padding(24)
  }
}
