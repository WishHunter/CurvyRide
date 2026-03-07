import SwiftUI

struct MapsView: View {
  @StateObject private var model = MapsModel()
  
  var body: some View {
    HomeMapView(model: model)
      .onAppear {
        model.load()
      }
  }
}
