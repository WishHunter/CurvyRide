import SwiftUI
import UIKit

public extension UIColor {
  private enum Constants {
    static let eightBitValue: Int = 255
    static let eightBitHex: Int = 0xff
    static let alphaOffset: Int = 24
    static let redOffset: Int = 16
    static let greenOffset: Int = 8

    static func restrict(value: Int) -> Int {
      guard value > .zero else { return .zero }
      return min(Constants.eightBitValue, value)
    }

    static func convertToRGB(value: Int) -> CGFloat {
      CGFloat(value) / CGFloat(Constants.eightBitValue)
    }

    static func extractRGBPart(from hex: Int, offset: Int) -> Int {
      (hex >> offset) & Constants.eightBitHex
    }
  }

  var color: Color { Color(self) }

  convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
    let red = min(255, max(red, .zero))
    let green = min(255, max(green, .zero))
    let blue = min(255, max(blue, .zero))

    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: alpha
    )
  }

  convenience init(_ netHex: Int, alpha: CGFloat = 1) {
    self.init(
      red: (netHex >> 16) & 0xff,
      green: (netHex >> 8) & 0xff,
      blue: netHex & 0xff,
      alpha: alpha
    )
  }

  convenience init(red: Int, green: Int, blue: Int, alpha: Int) {
    let redFixed = Constants.restrict(value: red)
    let greenFixed = Constants.restrict(value: green)
    let blueFixed = Constants.restrict(value: blue)
    let alphaFixed = Constants.restrict(value: alpha)

    self.init(
      red: Constants.convertToRGB(value: redFixed),
      green: Constants.convertToRGB(value: greenFixed),
      blue: Constants.convertToRGB(value: blueFixed),
      alpha: Constants.convertToRGB(value: alphaFixed)
    )
  }

  convenience init(netHexWithAlpha: Int) {
    self.init(
      red: Constants.extractRGBPart(from: netHexWithAlpha, offset: Constants.redOffset),
      green: Constants.extractRGBPart(from: netHexWithAlpha, offset: Constants.greenOffset),
      blue: netHexWithAlpha & Constants.eightBitHex,
      alpha: Constants.extractRGBPart(from: netHexWithAlpha, offset: Constants.alphaOffset)
    )
  }

  convenience init(light: Int, lAlpha: CGFloat = 1, dark: Int? = nil, dAlpha: CGFloat = 1) {
    self.init {
      if $0.userInterfaceStyle == .dark, let dark {
        return UIColor(dark, alpha: dAlpha)
      } else {
        return UIColor(light, alpha: lAlpha)
      }
    }
  }
}

public extension UIColor {
  var hexString: String? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    let multiplier = CGFloat(255.999999)

    guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
      return nil
    }

    if alpha == 1.0 {
      return String(
        format: "#%02lX%02lX%02lX",
        Int(red * multiplier),
        Int(green * multiplier),
        Int(blue * multiplier)
      )
    } else {
      return String(
        format: "#%02lX%02lX%02lX%02lX",
        Int(red * multiplier),
        Int(green * multiplier),
        Int(blue * multiplier),
        Int(alpha * multiplier)
      )
    }
  }
}
