import SwiftUI

enum PlannerMetricFocusField: Hashable {
  case duration
  case distanceLimit
}

enum PlannerMetricVisualStyle {
  case circular
  case speedometer(progress: Double, minLabel: String, maxLabel: String)
}

struct PlannerSurfaceCard<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    DSSurfaceCard {
      content
    }
  }
}

struct PlannerMetricCardView<CenterContent: View, Controls: View>: View {
  let title: String
  let caption: String
  let visualStyle: PlannerMetricVisualStyle
  private let centerContent: CenterContent
  private let controls: Controls

  init(
    title: String,
    caption: String,
    visualStyle: PlannerMetricVisualStyle = .circular,
    @ViewBuilder centerContent: () -> CenterContent,
    @ViewBuilder controls: () -> Controls
  ) {
    self.title = title
    self.caption = caption
    self.visualStyle = visualStyle
    self.centerContent = centerContent()
    self.controls = controls()
  }

  var body: some View {
    PlannerSurfaceCard {
      VStack(spacing: 16) {
        metricDisplay
        controls
      }
    }
  }

  @ViewBuilder
  private var metricDisplay: some View {
    switch visualStyle {
    case .circular:
      PlannerCircularMetricView(
        title: title,
        caption: caption,
        centerContent: { centerContent }
      )
    case let .speedometer(progress, minLabel, maxLabel):
      PlannerSpeedometerMetricView(
        title: title,
        caption: caption,
        progress: progress,
        minLabel: minLabel,
        maxLabel: maxLabel,
        centerContent: { centerContent }
      )
    }
  }
}

extension PlannerMetricCardView where CenterContent == PlannerMetricValueView {
  init(
    title: String,
    value: String,
    caption: String,
    visualStyle: PlannerMetricVisualStyle = .circular,
    @ViewBuilder controls: () -> Controls
  ) {
    self.init(
      title: title,
      caption: caption,
      visualStyle: visualStyle,
      centerContent: {
        PlannerMetricValueView(value: value)
      },
      controls: controls
    )
  }
}

struct PlannerCircularMetricView<CenterContent: View>: View {
  let title: String
  let caption: String
  private let centerContent: CenterContent

  init(
    title: String,
    caption: String,
    @ViewBuilder centerContent: () -> CenterContent
  ) {
    self.title = title
    self.caption = caption
    self.centerContent = centerContent()
  }

  var body: some View {
    VStack(spacing: 14) {
      Text(title)
        .font(\.title.small)
        .foregroundColor(\.content.primary)

      ZStack {
        Circle()
          .fill(Colors.current.background.base.color)
          .frame(width: 212, height: 212)

        Circle()
          .stroke(Colors.current.background.elevated.color, lineWidth: 20)
          .frame(width: 212, height: 212)

        Circle()
          .stroke(Colors.current.accent.primary.color.opacity(0.28), lineWidth: 10)
          .frame(width: 184, height: 184)

        PlannerMetricCenterStack(caption: caption) {
          centerContent
        }
      }
      .frame(maxWidth: .infinity)
    }
  }
}

struct PlannerSpeedometerMetricView<CenterContent: View>: View {
  let title: String
  let caption: String
  let progress: Double
  let minLabel: String
  let maxLabel: String
  private let centerContent: CenterContent

  init(
    title: String,
    caption: String,
    progress: Double,
    minLabel: String,
    maxLabel: String,
    @ViewBuilder centerContent: () -> CenterContent
  ) {
    self.title = title
    self.caption = caption
    self.progress = progress
    self.minLabel = minLabel
    self.maxLabel = maxLabel
    self.centerContent = centerContent()
  }

  private var clampedProgress: Double {
    min(max(progress, 0), 1)
  }

  private var progressAngle: Double {
    180 * (1 - clampedProgress)
  }

  var body: some View {
    VStack(spacing: 14) {
      Text(title)
        .font(\.title.small)
        .foregroundColor(\.content.primary)

      ZStack(alignment: .bottom) {
        RoundedRectangle(cornerRadius: Radii.current.large, style: .continuous)
          .fill(Colors.current.background.base.color)
          .frame(width: 240, height: 126)

        PlannerGaugeTickMarksView(progress: clampedProgress)
          .frame(width: 216, height: 112)

        PlannerGaugeArcShape(endAngle: 0)
          .stroke(
            Colors.current.background.elevated.color,
            style: StrokeStyle(lineWidth: 18, lineCap: .round)
          )
          .frame(width: 216, height: 112)

        PlannerGaugeArcShape(endAngle: progressAngle)
          .stroke(
            Colors.current.accent.primary.color.opacity(0.9),
            style: StrokeStyle(lineWidth: 10, lineCap: .round)
          )
          .frame(width: 216, height: 112)
          .animation(.spring(response: 0.26, dampingFraction: 0.86), value: clampedProgress)

        PlannerGaugeNeedleView(progress: clampedProgress)
          .frame(width: 216, height: 112)
          .animation(.spring(response: 0.26, dampingFraction: 0.86), value: clampedProgress)

        PlannerMetricCenterStack(caption: caption) {
          centerContent
        }
        .padding(.bottom, 12)

        HStack {
          Text(minLabel)
            .font(\.metric.small)
            .foregroundColor(\.content.secondary)

          Spacer()

          Text(maxLabel)
            .font(\.metric.small)
            .foregroundColor(\.content.secondary)
        }
        .padding(.horizontal, 18)
      }
      .frame(maxWidth: .infinity)
    }
  }
}

struct PlannerMetricValueView: View {
  let value: String

  var body: some View {
    Text(value)
      .font(value.count > 3 ? \.metric.medium : \.metric.large)
      .foregroundColor(\.accent.primary)
      .minimumScaleFactor(0.7)
      .lineLimit(1)
  }
}

struct PlannerMetricInputView: View {
  @Binding var text: String
  let field: PlannerMetricFocusField
  let focusedField: FocusState<PlannerMetricFocusField?>.Binding

  var body: some View {
    TextField("", text: $text)
      .textFieldStyle(.plain)
      .font(text.count > 3 ? \.metric.medium : \.metric.large)
      .foregroundColor(\.accent.primary)
      .multilineTextAlignment(.center)
      .keyboardType(.numberPad)
      .focused(focusedField, equals: field)
      .tint(\.accent.primary)
      .frame(width: 88)
  }
}

struct PlannerMetricSymbolView: View {
  let symbol: String

  var body: some View {
    Text(symbol)
      .font(\.metric.large)
      .foregroundColor(\.accent.primary)
      .minimumScaleFactor(0.7)
      .lineLimit(1)
  }
}

private struct PlannerMetricCenterStack<CenterContent: View>: View {
  let caption: String
  private let centerContent: CenterContent

  init(
    caption: String,
    @ViewBuilder centerContent: () -> CenterContent
  ) {
    self.caption = caption
    self.centerContent = centerContent()
  }

  var body: some View {
    VStack(spacing: 4) {
      centerContent

      Text(caption)
        .font(\.label.small)
        .foregroundColor(\.content.secondary)
    }
  }
}

struct PlannerMetricFooterView: View {
  let leading: String
  let trailing: String

  var body: some View {
    HStack {
      Text(leading)
        .font(\.body.small)
        .foregroundColor(\.content.secondary)

      Spacer(minLength: 8)

      Text(trailing)
        .font(\.metric.small)
        .foregroundColor(\.accent.primary)
    }
  }
}

private struct PlannerGaugeTickMarksView: View {
  let progress: Double

  private let tickCount = 8

  var body: some View {
    GeometryReader { geometry in
      let layout = PlannerGaugeLayout(size: geometry.size)

      ZStack {
        ForEach(0...tickCount, id: \.self) { index in
          let tickProgress = Double(index) / Double(tickCount)
          let angle = 180 * (1 - tickProgress)
          let isActive = tickProgress <= progress
          let tickHeight: CGFloat = index.isMultiple(of: 2) ? 14 : 10
          let point = layout.point(for: angle, radiusOffset: -2)

          RoundedRectangle(cornerRadius: 1.5, style: .continuous)
            .fill(isActive ? Colors.current.accent.primary.color : Colors.current.stroke.strong.color)
            .frame(width: 3, height: tickHeight)
            .rotationEffect(.degrees(90 - angle))
            .position(point)
        }
      }
    }
  }
}

private struct PlannerGaugeNeedleView: View {
  let progress: Double

  private var angle: Double {
    180 * (1 - progress)
  }

  var body: some View {
    GeometryReader { geometry in
      let layout = PlannerGaugeLayout(size: geometry.size)
      let markerCenter = layout.point(for: angle, radiusOffset: -18)

      Capsule(style: .continuous)
        .fill(Colors.current.accent.primary.color.opacity(0.42))
        .frame(width: 3, height: 11)
        .overlay {
          Capsule(style: .continuous)
            .strokeBorder(Colors.current.background.surface.color.opacity(0.35), lineWidth: 0.5)
        }
        .rotationEffect(.degrees(90 - angle))
        .position(markerCenter)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}

private struct PlannerGaugeArcShape: Shape {
  var endAngle: Double

  var animatableData: Double {
    get { endAngle }
    set { endAngle = newValue }
  }

  func path(in rect: CGRect) -> Path {
    let layout = PlannerGaugeLayout(size: rect.size)
    let clampedEndAngle = min(max(endAngle, 0), 180)
    let samples = max(24, Int(abs(180 - clampedEndAngle) / 3))

    var path = Path()

    guard samples > 0 else { return path }

    for sample in 0...samples {
      let fraction = Double(sample) / Double(samples)
      let angle = 180 + (clampedEndAngle - 180) * fraction
      let point = layout.point(for: angle)

      if sample == 0 {
        path.move(to: point)
      } else {
        path.addLine(to: point)
      }
    }

    return path
  }
}

private struct PlannerGaugeLayout {
  let size: CGSize

  var center: CGPoint {
    CGPoint(x: size.width / 2, y: size.height - 12)
  }

  var radius: CGFloat {
    min((size.width / 2) - 10, size.height - 20)
  }

  func point(for angle: Double, radiusOffset: CGFloat = 0) -> CGPoint {
    let radians = CGFloat(angle * .pi / 180)
    let resolvedRadius = radius + radiusOffset

    return CGPoint(
      x: center.x + CoreGraphics.cos(radians) * resolvedRadius,
      y: center.y - CoreGraphics.sin(radians) * resolvedRadius
    )
  }
}

struct PlannerToggleRowView: View {
  let title: String
  let subtitle: String?
  let isOn: Binding<Bool>
  var isDisabled: Bool = false

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(\.label.medium)
          .foregroundColor(\.content.primary)

        if let subtitle {
          Text(subtitle)
            .font(\.body.small)
            .foregroundColor(\.content.secondary)
        }
      }

      Spacer(minLength: 8)

      Toggle("", isOn: isOn)
        .labelsHidden()
        .tint(\.accent.primary)
        .disabled(isDisabled)
    }
  }
}

#Preview("Surface Card") {
  PlannerSurfaceCard {
    VStack(alignment: .leading, spacing: 8) {
      Text("Preview Card")
        .font(\.title.small)
        .foregroundColor(\.content.primary)
      Text("Reusable surface for planner sections")
        .font(\.body.small)
        .foregroundColor(\.content.secondary)
    }
  }
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Focus Card") {
  PlannerMetricCardView(
    title: "Duration",
    caption: "min",
    visualStyle: .speedometer(progress: 0.52, minLabel: "10", maxLabel: "240")
  ) {
    PlannerMetricValueView(value: "75")
  } controls: {
    PlannerMetricFooterView(leading: "Cap", trailing: "75 min")
  }
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Compact Toggle") {
  @Previewable @State var isOn = true

  return PlannerToggleRowView(
    title: "Fast Return",
    subtitle: "Shorter way back",
    isOn: $isOn
  )
  .padding()
  .background(Colors.current.background.base.color)
}
