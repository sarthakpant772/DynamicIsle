import SwiftUI

/// Main container view for the Dynamic Island - Always expanded
struct IslandContainerView: View {
    @ObservedObject var viewModel: IslandViewModel

    var body: some View {
        ZStack {
            // Background pill shape
            RoundedRectangle(cornerRadius: 28)
                .fill(.black)
                .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)

            // Content - Always show expanded view
            ExpandedIslandView(viewModel: viewModel)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
        .frame(width: 380, height: 200)
    }
}

#Preview {
    IslandContainerView(viewModel: IslandViewModel())
        .frame(width: 400, height: 220)
        .background(Color.gray.opacity(0.3))
}
