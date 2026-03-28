import MapKit
import SwiftUI

struct MapsView: View {
  @StateObject private var model = MapsModel()

  private var appTitle: String {
    fromInfoPlistOrFatal(key: "CFBundleDisplayName")
  }

  var body: some View {
    Map(position: $model.cameraPosition)
      .ignoresSafeArea()
      .onMapCameraChange(frequency: .continuous) { context in
        model.updateMapCenterCoordinate(context.region.center)
      }
      .sheet(isPresented: $model.isPlannerSheetPresented) {
        PlannerView(
          onShowOnMap: {
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
      .overlay {
        Image(systemName: "mappin.circle.fill")
          .font(.system(size: 34))
          .foregroundStyle(.red)
          .shadow(radius: 2)
      }
      .overlay(alignment: .topLeading) {
        Text(appTitle)
          .font(\.headline.large16)
          .foregroundColor(\.content.primary)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(.ultraThinMaterial, in: Capsule())
          .padding(.leading, 16)
          .padding(.top, 8)
      }
      .overlay(alignment: .top) {
        if model.isPickingStartPoint {
          Text("Move map to place the start point")
            .font(\.headline.medium14)
            .foregroundColor(\.content.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.top, 8)
        }
      }
      .overlay(alignment: .bottomLeading) {
        Text(model.routeSummary)
          .font(\.body.medium14)
          .foregroundColor(\.content.primary)
          .lineLimit(2)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
          .padding(.leading, 16)
          .padding(.bottom, 22)
      }
      .overlay(alignment: .bottom) {
        if model.isPickingStartPoint {
          HStack(spacing: 12) {
            Button("Cancel") {
              model.cancelStartPointPicking()
            }
            .buttonStyle(.bordered)

            Button("Apply") {
              model.applyStartPointPicking()
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.mapCenterCoordinate == nil)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(.ultraThinMaterial, in: Capsule())
          .padding(.bottom, 18)
        }
      }
      .overlay(alignment: .bottomTrailing) {
        VStack(spacing: 10) {
          Button("Show Me") {
            model.showMe()
          }
          .font(\.headline.medium14)
          .foregroundColor(\.content.primary)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(.ultraThinMaterial, in: Capsule())

          if model.isPickingStartPoint == false {
            Button {
              model.presentPlannerSheet()
            } label: {
              Image(systemName: "slider.horizontal.3")
                .foregroundColor(\.content.primary)
                .frame(width: 56, height: 56)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
            }
          }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 18)
      }
      .tint(\.accent.primary)
  }
}

#Preview {
  MapsView()
}
