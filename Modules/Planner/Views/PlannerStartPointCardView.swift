import SwiftUI

struct PlannerStartPointCardView: View {
  let startPoint: PlannerStartPoint?
  let isBusy: Bool
  @Binding var query: String
  let completions: [StartPointSearchCompletion]
  let onQueryChange: (String) -> Void
  let onSubmit: () -> Void
  let onSelectCompletion: (StartPointSearchCompletion) -> Void
  let onChooseOnMap: () -> Void
  let onUseCurrentLocation: () -> Void

  var body: some View {
    PlannerSurfaceCard {
      VStack(alignment: .leading, spacing: 14) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Start")
              .font(\.title.small)
              .foregroundColor(\.content.primary)

            startPointSummary
          }
        }

        searchBar

        HStack(spacing: 8) {
          DSButton(
            "Pin",
            systemImage: "mappin.and.ellipse",
            variant: .tertiary,
            size: .sm,
            isFullWidth: true,
            action: onChooseOnMap
          )
            .frame(maxWidth: .infinity)
            .disabled(isBusy)

          DSButton(
            "Current",
            systemImage: "location.fill",
            variant: .tertiary,
            size: .sm,
            isFullWidth: true,
            action: onUseCurrentLocation
          )
            .frame(maxWidth: .infinity)
            .disabled(isBusy)
        }
      }
    }
  }

  @ViewBuilder
  private var startPointSummary: some View {
    if let startPoint {
      VStack(alignment: .leading, spacing: 2) {
        if let displayName = startPoint.displayName, displayName.isEmpty == false {
          Text(displayName)
            .font(\.label.medium)
            .foregroundColor(\.content.primary)
        }

        Text("\(startPoint.latitude), \(startPoint.longitude)")
          .font(\.body.small)
          .foregroundColor(\.content.secondary)
      }
    } else {
      Text("Not set")
        .font(\.body.medium)
        .foregroundColor(\.content.secondary)
    }
  }

  private var searchBar: some View {
    VStack(alignment: .leading, spacing: 8) {
      TextField("Search a place", text: $query)
        .font(\.body.medium)
        .disabled(isBusy)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
          RoundedRectangle(cornerRadius: Radii.current.medium, style: .continuous)
            .fill(Colors.current.background.neutral.color)
        }
        .overlay {
          RoundedRectangle(cornerRadius: Radii.current.medium, style: .continuous)
            .strokeBorder(Colors.current.stroke.soft.color, lineWidth: 1)
        }
        .onChange(of: query) { _, newValue in
          onQueryChange(newValue)
        }
        .onSubmit(onSubmit)

      if completions.isEmpty == false {
        ForEach(completions) { completion in
          DSButton(variant: .tertiary, size: .sm, isFullWidth: true, labelAlignment: .leading) {
            onSelectCompletion(completion)
          } label: {
            VStack(alignment: .leading, spacing: 2) {
              Text(completion.title)
                .font(\.label.medium)
                .foregroundColor(\.content.primary)

              if completion.subtitle.isEmpty == false {
                Text(completion.subtitle)
                  .font(\.body.small)
                  .foregroundColor(\.content.secondary)
              }
            }
          }
          .disabled(isBusy)
        }
      }
    }
  }
}

#Preview("Start Point Card") {
  @Previewable @State var query = "Belgrade"

  return PlannerStartPointCardView(
    startPoint: PlannerStartPoint(
      latitude: 44.8125,
      longitude: 20.4612,
      displayName: "Belgrade Center"
    ),
    isBusy: false,
    query: $query,
    completions: [],
    onQueryChange: { _ in },
    onSubmit: {},
    onSelectCompletion: { _ in },
    onChooseOnMap: {},
    onUseCurrentLocation: {}
  )
  .padding()
  .background(Colors.current.background.base.color)
}

#Preview("Start Point Empty") {
  @Previewable @State var query = ""

  return PlannerStartPointCardView(
    startPoint: nil,
    isBusy: false,
    query: $query,
    completions: [],
    onQueryChange: { _ in },
    onSubmit: {},
    onSelectCompletion: { _ in },
    onChooseOnMap: {},
    onUseCurrentLocation: {}
  )
  .padding()
  .background(Colors.current.background.base.color)
}
