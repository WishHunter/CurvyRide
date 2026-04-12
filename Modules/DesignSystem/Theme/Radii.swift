import CoreGraphics
import SwiftUI

public typealias DSRadius = KeyPath<Radii, CGFloat>

public extension DSRadius {
  var value: CGFloat {
    Radii.current[keyPath: self]
  }
}

public struct Radii {
  public static var current = Radii()

  public let small: CGFloat = 14
  public let medium: CGFloat = 18
  public let large: CGFloat = 24
  public let xLarge: CGFloat = 30
  public let full: CGFloat = 999

  public init() {}
}

#Preview {
  func block(name: String, radius: DSRadius) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(name)
        .font(\.label.medium)
        .foregroundColor(\.content.primary)
      RoundedRectangle(cornerRadius: radius.value, style: .continuous)
        .fill(Colors.current.background.surface.color)
        .frame(width: 120, height: 60)
        .overlay {
          RoundedRectangle(cornerRadius: radius.value, style: .continuous)
            .stroke(Colors.current.stroke.soft.color, lineWidth: 1)
        }
    }
  }

  return HStack(alignment: .top, spacing: 18) {
    block(name: "Small", radius: \.small)
    block(name: "Medium", radius: \.medium)
    block(name: "Large", radius: \.large)
    block(name: "XL", radius: \.xLarge)
  }
  .padding(24)
  .background(Colors.current.background.base.color)
}
