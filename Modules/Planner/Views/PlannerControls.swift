import SwiftUI

enum PlannerTab: String, CaseIterable {
  case core = "Ride"
  case advanced = "Roads"
}

struct PlannerTabSelectorView: View {
  @Binding var selectedTab: PlannerTab

  var body: some View {
    HStack(spacing: 8) {
      ForEach(PlannerTab.allCases, id: \.self) { tab in
        Button {
          selectedTab = tab
        } label: {
          Text(tab.rawValue)
            .font(\.label.large)
            .foregroundColor(selectedTab == tab ? \.content.primary : \.content.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
              Capsule(style: .continuous)
                .fill(selectedTab == tab ? Colors.current.background.surface.color : .clear)
            }
            .overlay {
              if selectedTab == tab {
                Capsule(style: .continuous)
                  .strokeBorder(Colors.current.stroke.soft.color, lineWidth: 1)
              }
            }
            .shadow(selectedTab == tab ? \.subtle : \.none)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(6)
    .background {
      Capsule(style: .continuous)
        .fill(Colors.current.background.neutral.color)
    }
    .overlay {
      Capsule(style: .continuous)
        .strokeBorder(Colors.current.stroke.soft.color, lineWidth: 1)
    }
  }
}

struct PlannerInlineCapsuleButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(\.label.medium)
        .foregroundColor(\.content.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
          Capsule(style: .continuous)
            .fill(Colors.current.background.neutral.color)
        }
        .overlay {
          Capsule(style: .continuous)
            .strokeBorder(Colors.current.stroke.soft.color, lineWidth: 1)
        }
    }
    .buttonStyle(.plain)
  }
}

struct PlannerActionBarView: View {
  let isClearDisabled: Bool
  let onClear: () -> Void
  let onSurprise: () -> Void
  let onApply: () -> Void

  var body: some View {
    DSSurfaceCard {
      VStack(alignment: .leading, spacing: 14) {
        HStack(spacing: 10) {
          DSButton("Clear Start", variant: .tertiary, size: .sm, isFullWidth: true, action: onClear)
            .frame(width: 112)
            .disabled(isClearDisabled)

          DSButton("Random", variant: .secondary, size: .sm, isFullWidth: true, action: onSurprise)
            .frame(width: 104)

          DSButton("Apply", variant: .primary, size: .sm, isFullWidth: true, action: onApply)
            .frame(maxWidth: .infinity)
        }
      }
    }
    .shadow(\.floating)
  }
}

#Preview("Planner Tabs") {
  @Previewable @State var selectedTab: PlannerTab = .advanced

  return PlannerTabSelectorView(selectedTab: $selectedTab)
    .padding()
    .background(Colors.current.background.base.color)
}

#Preview("Inline Button") {
  PlannerInlineCapsuleButton(title: "Edit Ride", action: {})
    .padding()
    .background(Colors.current.background.base.color)
}

#Preview("Action Bar") {
  VStack {
    Spacer()
    PlannerActionBarView(
      isClearDisabled: false,
      onClear: {},
      onSurprise: {},
      onApply: {}
    )
  }
  .background(Colors.current.background.base.color)
}
