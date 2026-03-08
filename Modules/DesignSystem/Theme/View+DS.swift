import SwiftUI

public extension View {
  func font(_ font: DSFont) -> some View {
    self.font(Fonts.current[keyPath: font])
  }

  func foregroundColor(_ color: DSColor) -> some View {
    self.foregroundColor(Colors.current[keyPath: color].color)
  }

  func tint(_ color: DSColor) -> some View {
    self.tint(Colors.current[keyPath: color].color)
  }

  func backgroundColor(_ color: DSColor) -> some View {
    self.background(Colors.current[keyPath: color].color)
  }
}
