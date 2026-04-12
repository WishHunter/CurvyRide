import MapKit
import SwiftUI

struct MapsView: View {
  @StateObject private var model = MapsModel()

  private var appTitle: String {
    fromInfoPlistOrFatal(key: "CFBundleDisplayName")
  }

  var body: some View {
    ZStack {
      mapLayer

      MapsTopBarView(
        title: appTitle,
        statusTitle: model.statusTitle,
        isPickingStartPoint: model.isPickingStartPoint
      )
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .frame(maxHeight: .infinity, alignment: .top)

      if model.isPickingStartPoint {
        MapsStartPointPickingOverlayView(
          isApplyEnabled: model.mapCenterCoordinate != nil,
          onCancel: model.cancelStartPointPicking,
          onApply: model.applyStartPointPicking
        )
        .padding(.horizontal, 16)
        .padding(.top, 72)
        .padding(.bottom, 18)
      } else {
        mapsIdleChrome
      }
    }
    .sheet(isPresented: $model.isPlannerSheetPresented) {
      PlannerView(
        onPickStartPointOnMap: {
          if let coordinate = model.beginStartPointPicking() {
            model.cameraPosition = .region(
              MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
              )
            )
          }
        }
      )
    }
    .tint(\.accent.primary)
  }

  private var mapLayer: some View {
    Map(position: $model.cameraPosition) {
      UserAnnotation()
    }
    .ignoresSafeArea()
    .onMapCameraChange(frequency: .continuous) { context in
      model.updateMapCenterCoordinate(context.region.center)
    }
  }

  private var mapsIdleChrome: some View {
    HStack(alignment: .bottom, spacing: 16) {
      summaryCard

      Spacer(minLength: 0)

      MapsControlClusterView(
        showsPlannerButton: true,
        onShowMe: model.showMe,
        onOpenPlanner: model.presentPlannerSheet
      )
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 18)
    .frame(maxHeight: .infinity, alignment: .bottom)
  }

  @ViewBuilder
  private var summaryCard: some View {
    switch model.screenState {
    case .loading:
      DSStateCard(
        title: "Finding Start",
        message: "Trying to center on your current location.",
        tone: .loading
      )
      .frame(maxWidth: 300)
    case .empty:
      DSStateCard(
        title: "No Start Yet",
        message: "Open Planner to search, pin, or use current location.",
        tone: .empty,
        actionTitle: "Open Planner",
        action: model.presentPlannerSheet
      )
      .frame(maxWidth: 300)
    case .ready:
      MapsRouteCardView(
        title: model.summaryTitle,
        tags: model.summaryTags
      )
    case .error(let message):
      DSStateCard(
        title: "Location Unavailable",
        message: message,
        tone: .error,
        actionTitle: "OK",
        action: model.clearScreenError
      )
      .frame(maxWidth: 300)
    }
  }
}

#Preview {
  MapsView()
}
