import SwiftUI

struct PlannerChip: Identifiable {
  let title: String
  let style: Style

  var id: String {
    "\(title)-\(style == .accent ? "accent" : "neutral")"
  }

  enum Style {
    case neutral
    case accent
  }
}

struct PlannerSummaryCardView: View {
  let title: String
  let subtitle: String
  let chips: [PlannerChip]
  let showsEditCore: Bool
  let onEditCore: () -> Void

  var body: some View {
    PlannerSurfaceCard {
      VStack(alignment: .leading, spacing: 14) {
        HStack(alignment: .top, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text(title)
              .font(\.title.small)
              .foregroundColor(\.content.primary)
              .lineLimit(2)

            Text(subtitle)
              .font(\.body.small)
              .foregroundColor(\.content.secondary)
              .lineLimit(2)
          }

          Spacer(minLength: 8)

          if showsEditCore {
            PlannerInlineCapsuleButton(title: "Edit Ride", action: onEditCore)
          }
        }

        PlannerChipFlowView(chips: chips)
      }
    }
  }
}

struct PlannerChipFlowView: View {
  let chips: [PlannerChip]

  var body: some View {
    ViewThatFits(in: .vertical) {
      HStack(spacing: 8) {
        chipRow(chips)
      }

      VStack(alignment: .leading, spacing: 8) {
        chipRow(Array(chips.prefix(splitIndex)))

        if splitIndex < chips.count {
          chipRow(Array(chips.dropFirst(splitIndex)))
        }
      }
    }
  }

  private var splitIndex: Int {
    max(1, Int(ceil(Double(chips.count) / 2.0)))
  }

  private func chipRow(_ chips: [PlannerChip]) -> some View {
    ForEach(chips) { chip in
      DSChip(
        chip.title,
        tone: chip.style == .accent ? .accent : .neutral
      )
    }
  }
}

#Preview("Summary Card") {
  PlannerSummaryCardView(
    title: "Belgrade Center",
    subtitle: "Adjust the route before applying",
    chips: [
      .init(title: "60 min", style: .neutral),
      .init(title: "Loop", style: .accent),
      .init(title: "25 km", style: .neutral),
      .init(title: "Fast Return", style: .accent)
    ],
    showsEditCore: true,
    onEditCore: {}
  )
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Chip Flow") {
  PlannerChipFlowView(
    chips: [
      .init(title: "No Tolls", style: .neutral),
      .init(title: "Loop", style: .accent),
      .init(title: "Road Mix", style: .neutral)
    ]
  )
  .padding()
  .background(Colors.current.background.base.color)
}
