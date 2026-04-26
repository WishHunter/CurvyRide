import SwiftUI

struct PlannerView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedTab: PlannerTab = .core
  @State private var durationInput = ""
  @State private var distanceLimitInput = ""
  @FocusState private var focusedField: PlannerMetricFocusField?
  @StateObject private var model = PlannerModel()
  @StateObject private var searchService = StartPointSearchService()

  let onPickStartPointOnMap: () -> Void

  private let durationRange: ClosedRange<Int> = 10...240
  private let distanceRange: ClosedRange<Int> = 1...300

  var body: some View {
    VStack(spacing: 12) {
      PlannerSheetHandleView()
        .padding(.top, 8)

      PlannerSheetHeaderView(
        title: "Plan Ride",
        selectedTab: $selectedTab
      )

      if let feedbackState {
        DSStateCard(
          title: feedbackState.title,
          message: feedbackState.message,
          tone: feedbackState.tone,
          actionTitle: feedbackState.actionTitle,
          action: feedbackState.action
        )
        .padding(.horizontal, 16)
      }

      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 18) {
          currentTabContent
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 128)
      }
      .scrollDismissesKeyboard(.interactively)
    }
    .padding(.horizontal, 12)
    .background(Color.clear)
    .safeAreaInset(edge: .bottom) {
      PlannerActionBarView(
        isClearDisabled: model.settings.startPoint == nil,
        onClear: {
          model.send(.startPointSelected(nil))
        },
        onSurprise: {
          model.send(.surpriseMeTapped)
        },
        onApply: dismiss.callAsFunction
      )
      .padding(.horizontal, 12)
      .padding(.top, 8)
      .background(Color.clear)
    }
    .presentationDetents([.medium, .large])
    .presentationCornerRadius(Radii.current.xLarge + 4)
    .presentationBackground(.clear)
    .presentationDragIndicator(.hidden)
    .tint(\.accent.primary)
    .onAppear(perform: syncMetricInputs)
    .onChange(of: model.startPointFlowState) { oldValue, newValue in
      if case .searching = oldValue, case .idle = newValue, model.settings.startPoint != nil {
        searchService.clear()
      }
    }
    .onChange(of: model.settings.durationMinutes) { _, _ in
      guard focusedField != .duration else { return }
      durationInput = String(model.settings.durationMinutes)
    }
    .onChange(of: model.settings.distanceLimitKm) { _, _ in
      guard focusedField != .distanceLimit else { return }
      distanceLimitInput = model.settings.distanceLimitKm.map(String.init) ?? ""
    }
    .onChange(of: focusedField) { _, newField in
      if newField != .duration {
        durationInput = String(model.settings.durationMinutes)
      }

      if newField != .distanceLimit {
        distanceLimitInput = model.settings.distanceLimitKm.map(String.init) ?? ""
      }
    }
  }

  private var currentTabContent: some View {
    VStack(spacing: 14) {
      if selectedTab == .core {
        coreTab
      } else {
        advancedTab
      }
    }
  }

  private var coreTab: some View {
    VStack(spacing: 14) {
      PlannerStartPointCardView(
        startPoint: model.settings.startPoint,
        isBusy: model.startPointFlowState.isBusy,
        query: $searchService.query,
        completions: Array(searchService.completions.prefix(3)),
        onQueryChange: handleSearchQueryChange,
        onSubmit: handleSearchSubmit,
        onSelectCompletion: model.sendCompletion,
        onChooseOnMap: handleChooseOnMap,
        onUseCurrentLocation: {
          model.send(.useCurrentLocationTapped)
        }
      )
      
      PlannerMetricCardView(
        title: "Duration",
        caption: "min",
        visualStyle: .speedometer(
          progress: durationProgress,
          minLabel: "\(durationRange.lowerBound)",
          maxLabel: "\(durationRange.upperBound)"
        )
      ) {
        PlannerMetricInputView(
          text: durationInputBinding,
          field: .duration,
          focusedField: $focusedField
        )
      } controls: {
        Slider(
          value: Binding(
            get: { Double(model.settings.durationMinutes) },
            set: { model.send(.durationChanged(Int($0.rounded()))) }
          ),
          in: Double(durationRange.lowerBound)...Double(durationRange.upperBound),
          step: 5
        )
      }

      PlannerRouteTypeCardView(
        routeTypeSummary: model.settings.isLoopRoute ? "Loop" : "Point-to-Point",
        isLoopRoute: Binding(
          get: { model.settings.isLoopRoute },
          set: { model.send(.toggleChanged(.loopRoute, $0)) }
        )
      )
    }
  }

  private var advancedTab: some View {
    VStack(spacing: 14) {
      PlannerMetricCardView(
        title: "Distance",
        caption: model.settings.distanceLimitKm == nil ? "no cap" : "km cap",
        visualStyle: .speedometer(
          progress: distanceLimitProgress,
          minLabel: "\(distanceRange.lowerBound)",
          maxLabel: "\(distanceRange.upperBound)"
        )
      ) {
        if model.settings.distanceLimitKm == nil {
          PlannerMetricSymbolView(symbol: "∞")
        } else {
          PlannerMetricInputView(
            text: distanceLimitInputBinding,
            field: .distanceLimit,
            focusedField: $focusedField
          )
        }
      } controls: {
        PlannerToggleRowView(
          title: "Distance Cap",
          subtitle: model.settings.distanceLimitKm.map { "\($0) km" } ?? "Off",
          isOn: Binding(
            get: { model.settings.distanceLimitKm != nil },
            set: { model.send(.distanceLimitToggled($0)) }
          )
        )

        if model.settings.distanceLimitKm != nil {
          Slider(
            value: Binding(
              get: { Double(model.settings.distanceLimitKm ?? 25) },
              set: { model.send(.distanceLimitChanged(Int($0.rounded()))) }
            ),
            in: Double(distanceRange.lowerBound)...Double(distanceRange.upperBound),
            step: 1
          )

          PlannerMetricFooterView(
            leading: "Cap",
            trailing: "\(model.settings.distanceLimitKm ?? 0) km"
          )
        }

        PlannerToggleRowView(
          title: "Fast Return",
          subtitle: model.settings.isLoopRoute ? nil : "Loop only",
          isOn: Binding(
            get: { model.settings.isFastReturn },
            set: { model.send(.toggleChanged(.fastReturn, $0)) }
          ),
          isDisabled: model.settings.isLoopRoute == false
        )
      }

      PlannerRoadPreferencesCardView(
        avoidHighways: Binding(
          get: { model.settings.avoidHighways },
          set: { model.send(.toggleChanged(.avoidHighways, $0)) }
        ),
        avoidTolls: Binding(
          get: { model.settings.avoidTolls },
          set: { model.send(.toggleChanged(.avoidTolls, $0)) }
        )
      )
    }
  }

  private var durationProgress: Double {
    normalizedProgress(
      value: Double(model.settings.durationMinutes),
      range: Double(durationRange.lowerBound)...Double(durationRange.upperBound)
    )
  }

  private var distanceLimitProgress: Double {
    normalizedProgress(
      value: Double(model.settings.distanceLimitKm ?? distanceRange.lowerBound),
      range: Double(distanceRange.lowerBound)...Double(distanceRange.upperBound)
    )
  }

  private var durationInputBinding: Binding<String> {
    Binding(
      get: { durationInput },
      set: { newValue in
        let filtered = filteredNumericText(newValue, maximumLength: 3)
        durationInput = filtered

        guard let value = Int(filtered) else { return }
        model.send(.durationChanged(value))
      }
    )
  }

  private var distanceLimitInputBinding: Binding<String> {
    Binding(
      get: { distanceLimitInput },
      set: { newValue in
        let filtered = filteredNumericText(newValue, maximumLength: 3)
        distanceLimitInput = filtered

        guard let value = Int(filtered) else { return }
        model.send(.distanceLimitChanged(value))
      }
    )
  }

  private var feedbackState: PlannerFeedbackState? {
    switch model.startPointFlowState {
    case .idle:
      guard model.settings.startPoint == nil else { return nil }
      let trimmedQuery = searchService.query.trimmingCharacters(in: .whitespacesAndNewlines)
      guard trimmedQuery.isEmpty, searchService.completions.isEmpty else { return nil }
      return PlannerFeedbackState(
        title: "No Start Yet",
        message: "Search, use current location, or pin on map.",
        tone: .empty
      )
    case .locatingCurrentLocation:
      return PlannerFeedbackState(
        title: "Finding Location",
        message: "Setting a start from your current location.",
        tone: .loading
      )
    case .searching(let query):
      return PlannerFeedbackState(
        title: "Searching",
        message: "Looking for '\(query)'.",
        tone: .loading
      )
    case .error(let message):
      return PlannerFeedbackState(
        title: "Start Unavailable",
        message: message,
        tone: .error,
        actionTitle: "OK",
        action: {
          model.send(.clearStartPointFeedback)
        }
      )
    }
  }

  private func handleSearchSubmit() {
    if let completion = searchService.completions.first {
      model.sendCompletion(completion)
    } else {
      model.send(.searchSubmitted(searchService.query))
    }
  }

  private func handleSearchQueryChange(_ value: String) {
    model.send(.clearStartPointFeedback)
    searchService.updateQuery(value)
  }

  private func handleChooseOnMap() {
    model.send(.clearStartPointFeedback)
    onPickStartPointOnMap()
  }

}

private extension PlannerModel {
  func sendCompletion(_ completion: StartPointSearchCompletion) {
    send(.searchCompletionSelected(completion))
  }
}

private extension PlannerView {
  func normalizedProgress(value: Double, range: ClosedRange<Double>) -> Double {
    guard range.upperBound > range.lowerBound else { return 0 }
    let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    return min(max(normalized, 0), 1)
  }

  func syncMetricInputs() {
    durationInput = String(model.settings.durationMinutes)
    distanceLimitInput = model.settings.distanceLimitKm.map(String.init) ?? ""
  }

  func filteredNumericText(_ text: String, maximumLength: Int) -> String {
    String(text.filter(\.isNumber).prefix(maximumLength))
  }
}

private struct PlannerFeedbackState {
  let title: String
  let message: String
  let tone: DSStateCard.Tone
  var actionTitle: String? = nil
  var action: (() -> Void)? = nil
}

#Preview {
  PlannerView(onPickStartPointOnMap: {})
}
