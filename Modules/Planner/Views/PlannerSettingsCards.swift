import SwiftUI

struct PlannerRouteTypeCardView: View {
  let routeTypeSummary: String
  let isLoopRoute: Binding<Bool>

  var body: some View {
    PlannerSurfaceCard {
      VStack(alignment: .leading, spacing: 14) {
        HStack {
          Text("Route")
            .font(\.title.small)
            .foregroundColor(\.content.primary)

          Spacer(minLength: 8)

          Text(routeTypeSummary)
            .font(\.label.medium)
            .foregroundColor(\.accent.primary)
        }

        Toggle("Loop", isOn: isLoopRoute)
          .tint(\.accent.primary)
      }
    }
  }
}

struct PlannerRoadPreferencesCardView: View {
  let avoidHighways: Binding<Bool>
  let avoidTolls: Binding<Bool>

  var body: some View {
    PlannerSurfaceCard {
      VStack(alignment: .leading, spacing: 12) {
        PlannerToggleRowView(
          title: "Highways",
          subtitle: avoidHighways.wrappedValue ? "Avoided" : "Allowed",
          isOn: avoidHighways
        )

        Rectangle()
          .fill(Colors.current.stroke.soft.color)
          .frame(height: 1)

        PlannerToggleRowView(
          title: "Tolls",
          subtitle: avoidTolls.wrappedValue ? "Avoided" : "Allowed",
          isOn: avoidTolls
        )
      }
    }
  }
}

#Preview("Route Type Card") {
  @Previewable @State var isLoopRoute = true

  return PlannerRouteTypeCardView(
    routeTypeSummary: "Loop",
    isLoopRoute: $isLoopRoute
  )
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Road Preferences") {
  @Previewable @State var avoidHighways = false
  @Previewable @State var avoidTolls = true

  return PlannerRoadPreferencesCardView(
    avoidHighways: $avoidHighways,
    avoidTolls: $avoidTolls
  )
  .padding()
  .background(Colors.current.background.base.color)
}
