import SwiftUI

public extension View {
  func font(_ font: DSFont) -> some View {
    self.font(font.font)
  }

  func foregroundColor(_ color: DSColor) -> some View {
    self.foregroundColor(color.color)
  }

  func tint(_ color: DSColor) -> some View {
    self.tint(color.color)
  }

  func backgroundColor(_ color: DSColor) -> some View {
    self.background(color.color)
  }

  func cornerRadius(_ radius: DSRadius, style: RoundedCornerStyle = .continuous) -> some View {
    clipShape(RoundedRectangle(cornerRadius: radius.value, style: style))
  }

  func shadow(_ shadow: DSShadow) -> some View {
    self.shadow(shadow.style)
  }

  func shadow(_ style: DSShadowStyle) -> some View {
    return self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}
