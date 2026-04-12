import SwiftUI

struct PlannerSheetHandleView: View {
  var body: some View {
    Capsule(style: .continuous)
      .fill(Colors.current.stroke.strong.color)
      .frame(width: 46, height: 6)
  }
}

struct PlannerSheetHeaderView: View {
  let title: String
  @Binding var selectedTab: PlannerTab

  var body: some View {
    DSSurfaceCard(tone: .muted) {
      VStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 6) {
          Text(title)
            .font(\.title.medium)
            .foregroundColor(\.content.primary)
        }

        PlannerTabSelectorView(selectedTab: $selectedTab)
      }
    }
  }
}

struct PlannerSectionHeaderView: View {
  let eyebrow: String
  let title: String
  let subtitle: String

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(eyebrow)
        .font(\.label.small)
        .foregroundColor(\.content.secondary)

      Text(title)
        .font(\.title.medium)
        .foregroundColor(\.content.primary)

      Text(subtitle)
        .font(\.body.small)
        .foregroundColor(\.content.secondary)
    }
  }
}

#Preview("Sheet Header") {
  @Previewable @State var selectedTab: PlannerTab = .core

  return VStack(spacing: 12) {
    PlannerSheetHandleView()
    PlannerSheetHeaderView(
      title: "Plan Ride",
      selectedTab: $selectedTab
    )
  }
  .padding()
  .background(Colors.current.background.base.color)
}
