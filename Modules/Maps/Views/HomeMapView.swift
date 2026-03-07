import SwiftUI

struct HomeMapView: View {
  @ObservedObject var model: MapsModel
  
  var body: some View {
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()
      
      VStack(spacing: 8) {
        Text(model.homeTitle)
          .font(.title2.weight(.semibold))
        Text("Start from: \(model.startPointSummary)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
  }
}
