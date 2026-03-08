import SwiftUI

struct PlannerView: View {
  let startPointSummary: String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Planner")
        .font(\.heading.h5)
        .foregroundColor(\.content.primary)

      Text("Start from: \(startPointSummary)")
        .font(\.body.medium14)
        .foregroundColor(\.content.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding(20)
    .presentationDetents([.medium, .large])
    .backgroundColor(\.background.base)
  }
}

#Preview {
  PlannerView(startPointSummary: "Current location")
}
