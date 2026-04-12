import SwiftUI

public struct DSButton: View {
  public enum Variant {
    case primary
    case secondary
    case tertiary
    case destructive
  }

  public enum Size {
    case sm
    case md
    case fab
  }

  private let title: String?
  private let systemImage: String?
  private let customLabel: AnyView?
  private let variant: Variant
  private let size: Size
  private let isFullWidth: Bool
  private let labelAlignment: Alignment
  private let action: () -> Void

  public init(
    _ title: String,
    systemImage: String? = nil,
    variant: Variant = .primary,
    size: Size = .md,
    isFullWidth: Bool = false,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.systemImage = systemImage
    self.customLabel = nil
    self.variant = variant
    self.size = size
    self.isFullWidth = isFullWidth
    self.labelAlignment = .center
    self.action = action
  }

  public init(
    icon systemImage: String,
    variant: Variant = .tertiary,
    size: Size = .md,
    action: @escaping () -> Void
  ) {
    self.title = nil
    self.systemImage = systemImage
    self.customLabel = nil
    self.variant = variant
    self.size = size
    self.isFullWidth = false
    self.labelAlignment = .center
    self.action = action
  }

  public init(
    variant: Variant = .tertiary,
    size: Size = .md,
    isFullWidth: Bool = false,
    labelAlignment: Alignment = .center,
    action: @escaping () -> Void,
    @ViewBuilder label: () -> some View
  ) {
    self.title = nil
    self.systemImage = nil
    self.customLabel = AnyView(label())
    self.variant = variant
    self.size = size
    self.isFullWidth = isFullWidth
    self.labelAlignment = labelAlignment
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      buttonLabel
    }
    .buttonStyle(
      DSButtonStyle(
        variant: variant,
        size: size,
        isIconOnly: isIconOnly
      )
    )
  }

  @ViewBuilder
  private var buttonLabel: some View {
    if let customLabel {
      customLabel
        .frame(maxWidth: isFullWidth ? .infinity : nil, alignment: labelAlignment)
    } else if let title {
      HStack(spacing: 8) {
        if let systemImage {
          Image(systemName: systemImage)
        }
        Text(title)
      }
      .font(size.labelFont)
      .frame(maxWidth: isFullWidth ? .infinity : nil, alignment: labelAlignment)
    } else if let systemImage {
      Image(systemName: systemImage)
        .font(size.iconFont)
        .frame(width: size.iconFrame, height: size.iconFrame)
    }
  }

  private var isIconOnly: Bool {
    title == nil && customLabel == nil
  }
}

private extension DSButton.Size {
  var labelFont: DSFont {
    switch self {
    case .sm:
      return \.label.medium
    case .md, .fab:
      return \.label.large
    }
  }

  var iconFont: DSFont {
    switch self {
    case .sm:
      return \.label.medium
    case .md, .fab:
      return \.title.small
    }
  }

  var iconFrame: CGFloat {
    switch self {
    case .sm:
      return 36
    case .md:
      return 44
    case .fab:
      return 56
    }
  }

  var contentInsets: EdgeInsets {
    switch self {
    case .sm:
      return EdgeInsets(top: 9, leading: 14, bottom: 9, trailing: 14)
    case .md:
      return EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16)
    case .fab:
      return EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
    }
  }

  var controlSize: CGFloat {
    switch self {
    case .sm:
      return 40
    case .md:
      return 48
    case .fab:
      return 56
    }
  }

  var cornerRadius: CGFloat {
    switch self {
    case .sm:
      return Radii.current.medium
    case .md, .fab:
      return Radii.current.large
    }
  }
}

private extension DSButton.Variant {
  var foregroundColor: Color {
    switch self {
    case .primary:
      return Colors.current.content.inverse.color
    case .secondary:
      return Colors.current.content.onAccent.color
    case .tertiary:
      return Colors.current.content.primary.color
    case .destructive:
      return Colors.current.accent.negative.color
    }
  }

  var backgroundColor: Color {
    switch self {
    case .primary:
      return Colors.current.background.strong.color
    case .secondary:
      return Colors.current.accent.primary.color
    case .tertiary:
      return Colors.current.background.surface.color
    case .destructive:
      return Colors.current.background.negative.color
    }
  }

  var borderColor: Color? {
    switch self {
    case .primary, .secondary:
      return nil
    case .tertiary:
      return Colors.current.stroke.soft.color
    case .destructive:
      return Colors.current.stroke.negative.color
    }
  }

  var restingShadow: DSShadowStyle {
    switch self {
    case .primary, .secondary:
      return Shadows.current.floating
    case .tertiary, .destructive:
      return Shadows.current.soft
    }
  }
}

private struct DSButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled

  let variant: DSButton.Variant
  let size: DSButton.Size
  let isIconOnly: Bool

  func makeBody(configuration: Configuration) -> some View {
    let appearance = appearance(isPressed: configuration.isPressed)

    configuration.label
      .foregroundStyle(appearance.foregroundColor)
      .padding(isIconOnly ? EdgeInsets() : size.contentInsets)
      .frame(
        minWidth: isIconOnly ? size.controlSize : nil,
        minHeight: size.controlSize
      )
      .background { background(using: appearance) }
      .overlay { border(using: appearance) }
      .shadow(appearance.shadowStyle)
      .opacity(configuration.isPressed ? 0.96 : 1.0)
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.spring(response: 0.22, dampingFraction: 0.84), value: configuration.isPressed)
  }

  private func appearance(isPressed: Bool) -> Appearance {
    guard isEnabled else {
      return Appearance(
        foregroundColor: Colors.current.content.disabled.color,
        backgroundColor: Colors.current.background.disabled.color,
        borderColor: nil,
        shadowStyle: Shadows.current.none
      )
    }

    return Appearance(
      foregroundColor: variant.foregroundColor,
      backgroundColor: variant.backgroundColor,
      borderColor: variant.borderColor,
      shadowStyle: isPressed ? Shadows.current.subtle : variant.restingShadow
    )
  }

  @ViewBuilder
  private func background(using appearance: Appearance) -> some View {
    if isIconOnly {
      Circle()
        .fill(appearance.backgroundColor)
    } else {
      RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
        .fill(appearance.backgroundColor)
    }
  }

  @ViewBuilder
  private func border(using appearance: Appearance) -> some View {
    if let borderColor = appearance.borderColor {
      if isIconOnly {
        Circle()
          .strokeBorder(borderColor, lineWidth: 1)
      } else {
        RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
          .strokeBorder(borderColor, lineWidth: 1)
      }
    }
  }

  private struct Appearance {
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color?
    let shadowStyle: DSShadowStyle
  }
}

#Preview {
  VStack(spacing: 16) {
    HStack(spacing: 12) {
      DSButton("Primary", variant: .primary, action: {})
      DSButton("Accent", variant: .secondary, action: {})
      DSButton("Ghost", variant: .tertiary, action: {})
    }

    HStack(spacing: 12) {
      DSButton(icon: "location.fill", variant: .tertiary, size: .md, action: {})
      DSButton(icon: "slider.horizontal.3", variant: .secondary, size: .fab, action: {})
      DSButton("Delete", variant: .destructive, size: .sm, action: {})
    }

    DSButton("Full Width", variant: .primary, size: .md, isFullWidth: true, action: {})
  }
  .padding(24)
  .background(Colors.current.background.base.color)
}
