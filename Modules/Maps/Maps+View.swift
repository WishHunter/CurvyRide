import MapKit
import SwiftUI

struct MapsView: View {
  @StateObject private var model = MapsModel()
  @State private var isPlannerSheetPresented = false
  @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
  
  private var appTitle: String {
    fromInfoPlistOrFatal(key: "CFBundleDisplayName")
  }

  var body: some View {
    Map(position: $cameraPosition)
      .ignoresSafeArea()
      .sheet(isPresented: $isPlannerSheetPresented) {
        PlannerView(startPointSummary: model.startPointSummary)
      }
      .overlay(alignment: .bottomTrailing) {
        Button {
          isPlannerSheetPresented = true
        } label: {
          Image(systemName: "slider.horizontal.3")
            .foregroundColor(\.content.primary)
            .frame(width: 56, height: 56)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
        }
        .padding(.trailing, 20)
        .padding(.bottom, 18)
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
      .task {
        model.load()
      }
      .tint(\.accent.primary)
  }
}

#Preview {
  MapsView()
}
