import SwiftUI

struct MapsTopBarView: View {
  let title: String
  let statusTitle: String
  let isPickingStartPoint: Bool

  var body: some View {
    HStack(spacing: 12) {
      HStack(spacing: 10) {
        Circle()
          .fill(Colors.current.accent.primary.color)
          .frame(width: 10, height: 10)

        Text(title)
          .font(\.label.large)
          .foregroundColor(\.content.primary)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background {
        Capsule(style: .continuous)
          .fill(Colors.current.background.surface.color)
      }
      .overlay {
        Capsule(style: .continuous)
          .strokeBorder(Colors.current.stroke.soft.color, lineWidth: 1)
      }
      .shadow(\.soft)

      Spacer(minLength: 12)

      MapsStatusBadgeView(
        title: isPickingStartPoint ? "Pin Start" : statusTitle,
        isAccent: isPickingStartPoint
      )
    }
  }
}

struct MapsRouteCardView: View {
  let title: String
  let tags: [MapsSummaryTag]

  var body: some View {
    DSSurfaceCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack(alignment: .top, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Ride")
              .font(\.label.small)
              .foregroundColor(\.content.secondary)

            Text(title)
              .font(\.title.medium)
              .foregroundColor(\.content.primary)
              .lineLimit(2)
          }

          Spacer(minLength: 8)

          Image(systemName: "road.lanes.curved.right")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Colors.current.accent.primary.color)
            .padding(12)
            .background {
              RoundedRectangle(cornerRadius: Radii.current.medium, style: .continuous)
                .fill(Colors.current.background.neutral.color)
            }
        }

        MapsTagFlowView(tags: tags)
      }
    }
    .frame(maxWidth: 300)
  }
}

struct MapsControlClusterView: View {
  let showsPlannerButton: Bool
  let onShowMe: () -> Void
  let onOpenPlanner: () -> Void

  var body: some View {
    DSSurfaceCard(tone: .muted) {
      VStack(spacing: 10) {
        DSButton(icon: "location.fill", variant: .tertiary, size: .md, action: onShowMe)
          .accessibilityLabel("Show Current Location")

        if showsPlannerButton {
          DSButton(icon: "slider.horizontal.3", variant: .secondary, size: .fab, action: onOpenPlanner)
            .accessibilityLabel("Open Planner")
        }
      }
      .frame(width: 56)
      .frame(maxWidth: .infinity)
    }
    .frame(width: 88)
  }
}

struct MapsStartPointPickingOverlayView: View {
  let isApplyEnabled: Bool
  let onCancel: () -> Void
  let onApply: () -> Void

  var body: some View {
    ZStack {
      VStack {
        DSSurfaceCard(tone: .muted) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Pin Start")
              .font(\.title.small)
              .foregroundColor(\.content.primary)

            Text("Move the map until the pin sits where you want to start.")
              .font(\.body.small)
              .foregroundColor(\.content.secondary)
          }
        }
        .frame(maxWidth: 320)

        Spacer()
      }

      MapsCenterPinView()

      VStack {
        Spacer()

        DSSurfaceCard {
          VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
              Text("Start Preview")
                .font(\.label.small)
                .foregroundColor(\.content.secondary)

              Text("Use this pin to return to the planner.")
                .font(\.body.small)
                .foregroundColor(\.content.primary)
            }

            HStack(spacing: 10) {
              DSButton("Cancel", variant: .tertiary, size: .md, isFullWidth: true, action: onCancel)
                .frame(maxWidth: .infinity)

              DSButton(
                "Use Pin",
                systemImage: "checkmark",
                variant: .primary,
                size: .md,
                isFullWidth: true,
                action: onApply
              )
                .frame(maxWidth: .infinity)
                .disabled(isApplyEnabled == false)
            }
          }
        }
      }
    }
  }
}

private struct MapsStatusBadgeView: View {
  let title: String
  let isAccent: Bool

  var body: some View {
    Text(title)
      .font(\.label.medium)
      .foregroundColor(isAccent ? \.accent.secondary : \.content.secondary)
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .background {
        Capsule(style: .continuous)
          .fill(isAccent ? Colors.current.accent.primary.color.opacity(0.14) : Colors.current.background.surface.color)
      }
      .overlay {
        Capsule(style: .continuous)
          .strokeBorder(
            isAccent ? Colors.current.stroke.accent.color : Colors.current.stroke.soft.color,
            lineWidth: 1
          )
      }
      .shadow(\.subtle)
  }
}

private struct MapsTagFlowView: View {
  let tags: [MapsSummaryTag]

  var body: some View {
    MapsChipWrapLayout(itemSpacing: 8, rowSpacing: 8) {
      ForEach(tags) { tag in
        DSChip(tag.title, tone: tag.tone == .accent ? .accent : .neutral)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct MapsChipWrapLayout: Layout {
  let itemSpacing: CGFloat
  let rowSpacing: CGFloat

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    let maxWidth = proposal.width ?? .infinity
    let rows = arrangeRows(in: maxWidth, subviews: subviews)

    let width = rows.map(\.width).max() ?? 0
    let height = rows.reduce(0) { partialResult, row in
      partialResult + row.height
    } + rowSpacing * CGFloat(max(rows.count - 1, 0))

    return CGSize(width: width, height: height)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    let rows = arrangeRows(in: bounds.width, subviews: subviews)
    var currentY = bounds.minY

    for row in rows {
      var currentX = bounds.minX

      for element in row.elements {
        let size = subviews[element.index].sizeThatFits(.unspecified)
        subviews[element.index].place(
          at: CGPoint(x: currentX, y: currentY),
          anchor: .topLeading,
          proposal: ProposedViewSize(size)
        )
        currentX += size.width + itemSpacing
      }

      currentY += row.height + rowSpacing
    }
  }

  private func arrangeRows(in maxWidth: CGFloat, subviews: Subviews) -> [Row] {
    let availableWidth = max(maxWidth, 1)
    var rows: [Row] = []
    var currentRow = Row()

    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(.unspecified)
      let proposedWidth = currentRow.elements.isEmpty
        ? size.width
        : currentRow.width + itemSpacing + size.width

      if proposedWidth > availableWidth, currentRow.elements.isEmpty == false {
        rows.append(currentRow)
        currentRow = Row()
      }

      currentRow.elements.append(Row.Element(index: index))
      currentRow.width = currentRow.elements.count == 1
        ? size.width
        : currentRow.width + itemSpacing + size.width
      currentRow.height = max(currentRow.height, size.height)
    }

    if currentRow.elements.isEmpty == false {
      rows.append(currentRow)
    }

    return rows
  }

  private struct Row {
    struct Element {
      let index: Int
    }

    var elements: [Element] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
  }
}

private struct MapsCenterPinView: View {
  var body: some View {
    ZStack {
      Circle()
        .fill(Colors.current.background.surface.color)
        .frame(width: 66, height: 66)
        .shadow(\.soft)

      Circle()
        .stroke(Colors.current.accent.primary.color.opacity(0.24), lineWidth: 10)
        .frame(width: 54, height: 54)

      Image(systemName: "mappin.circle.fill")
        .font(.system(size: 32))
        .foregroundStyle(Colors.current.accent.primary.color)
    }
  }
}

#Preview("Top Bar") {
  MapsTopBarView(
    title: "CurvyRide",
    statusTitle: "Loop route",
    isPickingStartPoint: false
  )
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Route Card") {
  MapsRouteCardView(
    title: "Belgrade Center",
    tags: [
      .init(title: "60 min", tone: .neutral),
      .init(title: "Loop", tone: .accent),
      .init(title: "Road mix", tone: .neutral)
    ]
  )
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Picking Overlay") {
  ZStack {
    Colors.current.background.base.color
      .ignoresSafeArea()

    MapsStartPointPickingOverlayView(
      isApplyEnabled: true,
      onCancel: {},
      onApply: {}
    )
    .padding(16)
  }
}
