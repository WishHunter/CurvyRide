import SwiftUI

public struct DSShadowStyle {
  public let color: Color
  public let radius: CGFloat
  public let x: CGFloat
  public let y: CGFloat

  public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
    self.color = color
    self.radius = radius
    self.x = x
    self.y = y
  }
}

public typealias DSShadow = KeyPath<Shadows, DSShadowStyle>

public extension DSShadow {
  var style: DSShadowStyle {
    Shadows.current[keyPath: self]
  }
}

public struct Shadows {
  public static var current = Shadows()

  public let none = DSShadowStyle(color: .clear, radius: 0)
  public let subtle = Self.shadow(
    lightAlpha: 0.08,
    darkAlpha: 0.22,
    radius: 8,
    y: 3
  )
  public let soft = Self.shadow(
    lightAlpha: 0.10,
    darkAlpha: 0.26,
    radius: 16,
    y: 8
  )
  public let floating = Self.shadow(
    lightAlpha: 0.12,
    darkAlpha: 0.30,
    radius: 24,
    y: 12
  )

  public init() {}

  private static func shadow(
    lightAlpha: CGFloat,
    darkAlpha: CGFloat,
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> DSShadowStyle {
    DSShadowStyle(
      color: UIColor(light: 0x3B2F23, lAlpha: lightAlpha, dark: 0x000000, dAlpha: darkAlpha).color,
      radius: radius,
      x: x,
      y: y
    )
  }
}

#Preview {
  func block(name: String, shadow: DSShadow) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(name)
        .font(\.label.medium)
        .foregroundColor(\.content.primary)
      RoundedRectangle(cornerRadius: Radii.current.large, style: .continuous)
        .fill(Colors.current.background.surface.color)
        .frame(width: 140, height: 74)
        .shadow(shadow)
    }
  }

  return HStack(alignment: .top, spacing: 24) {
    block(name: "Subtle", shadow: \.subtle)
    block(name: "Soft", shadow: \.soft)
    block(name: "Floating", shadow: \.floating)
  }
  .padding(24)
  .background(Colors.current.background.base.color)
}
