import SwiftUI

struct PlannerView: View {
  @StateObject private var model = PlannerModel()
  @StateObject private var searchService = StartPointSearchService()

  let onShowOnMap: () -> Void

  private let durationRange: ClosedRange<Int> = 10...240
  private let distanceRange: ClosedRange<Int> = 1...300

  var body: some View {
    NavigationStack {
      Form {
        Section("Route") {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Duration")
              Spacer()
              Text("\(model.settings.durationMinutes) min")
                .foregroundColor(\.content.secondary)
            }

            Slider(
              value: durationSliderBinding,
              in: Double(durationRange.lowerBound)...Double(durationRange.upperBound),
              step: 5
            )
          }

          Toggle(
            "Loop route",
            isOn: boolBinding(for: \.isLoopRoute)
          )

          if model.settings.isLoopRoute {
            Toggle(
              "Fast return",
              isOn: boolBinding(for: \.isFastReturn)
            )
          }

          Button("Surprise me") {
            model.applyRandomSettings()
          }
        }

        Section("Distance limit") {
          Toggle(
            "Enable distance limit",
            isOn: distanceLimitEnabledBinding
          )

          if model.settings.distanceLimitKm != nil {
            Stepper(
              value: distanceLimitBinding,
              in: distanceRange,
              step: 1
            ) {
              HStack {
                Text("Max distance")
                Spacer()
                Text("\(model.settings.distanceLimitKm ?? 0) km")
                  .foregroundColor(\.content.secondary)
              }
            }
          }
        }

        Section("Road preferences") {
          Toggle(
            "Avoid highways",
            isOn: boolBinding(for: \.avoidHighways)
          )

          Toggle(
            "Avoid tolls",
            isOn: boolBinding(for: \.avoidTolls)
          )
        }

        Section("Start point") {
          TextField("Search place", text: $searchService.query)
            .onChange(of: searchService.query) { _, newValue in
              searchService.updateQuery(newValue)
            }
            .onSubmit {
              Task {
                if let completion = searchService.completions.first,
                   let startPoint = await model.searchStartPoint(completion: completion) {
                  model.setStartPoint(startPoint)
                  searchService.clear()
                } else if let startPoint = await model.searchStartPoint(query: searchService.query) {
                  model.setStartPoint(startPoint)
                  searchService.clear()
                }
              }
            }

          if searchService.completions.isEmpty == false {
            ForEach(searchService.completions.prefix(5)) { completion in
              Button {
                Task {
                  if let startPoint = await model.searchStartPoint(completion: completion) {
                    model.setStartPoint(startPoint)
                    searchService.clear()
                  }
                }
              } label: {
                VStack(alignment: .leading, spacing: 2) {
                  Text(completion.title)
                    .foregroundColor(\.content.primary)
                  if completion.subtitle.isEmpty == false {
                    Text(completion.subtitle)
                      .font(\.body.small12)
                      .foregroundColor(\.content.secondary)
                  }
                }
              }
            }
          }

          HStack {
            Button("My current location") {
              Task {
                await model.useCurrentLocation()
              }
            }
            .buttonStyle(.borderless)

            Spacer(minLength: 12)

            Button("Show on map") {
              onShowOnMap()
            }
            .buttonStyle(.borderless)
          }

          if let startPoint = model.settings.startPoint {
            VStack(alignment: .leading, spacing: 6) {
              if let displayName = startPoint.displayName, displayName.isEmpty == false {
                Text(displayName)
              }
              Text("\(startPoint.latitude), \(startPoint.longitude)")
                .font(\.body.small12)
                .foregroundColor(\.content.secondary)
            }

            Button("Clear start point") {
              model.setStartPoint(nil)
            }
          } else {
            Text("Not selected")
              .foregroundColor(\.content.secondary)
          }
        }
      }
      .navigationTitle("Planner")
      .presentationDetents([.medium, .large])
      .tint(\.accent.primary)
    }
  }

  private var durationSliderBinding: Binding<Double> {
    Binding(
      get: { Double(model.settings.durationMinutes) },
      set: { model.setDuration(Int($0.rounded())) }
    )
  }

  private var distanceLimitEnabledBinding: Binding<Bool> {
    Binding(
      get: { model.settings.distanceLimitKm != nil },
      set: { model.setDistanceLimitEnabled($0) }
    )
  }

  private var distanceLimitBinding: Binding<Int> {
    Binding(
      get: { model.settings.distanceLimitKm ?? 25 },
      set: { model.setDistanceLimit($0) }
    )
  }

  private func boolBinding(for keyPath: WritableKeyPath<PlannerSettings, Bool>) -> Binding<Bool> {
    Binding(
      get: { model.settings[keyPath: keyPath] },
      set: { model.set($0, for: keyPath) }
    )
  }
}

#Preview {
  PlannerView(onShowOnMap: {})
}
