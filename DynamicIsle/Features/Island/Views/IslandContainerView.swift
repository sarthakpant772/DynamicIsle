import SwiftUI
import UniformTypeIdentifiers

/// Main container view for the Dynamic Island - Always expanded
struct IslandContainerView: View {
    @ObservedObject var viewModel: IslandViewModel
    @State private var isDropTargeted = false

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
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(isDropTargeted ? Color.cyan : Color.clear, lineWidth: 2)
                .allowsHitTesting(false)
        }
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted) { providers in
            guard !providers.isEmpty else { return false }
            for provider in providers where provider.canLoadObject(ofClass: NSURL.self) {
                _ = provider.loadObject(ofClass: NSURL.self) { object, _ in
                    guard let url = object as? URL, url.isFileURL else { return }
                    DispatchQueue.main.async {
                        if FileShelfStore.shared.add([url]) > 0 {
                            viewModel.switchToMode(.fileShelf)
                        }
                    }
                }
            }
            return true
        }
    }
}

#Preview {
    IslandContainerView(viewModel: IslandViewModel())
        .frame(width: 400, height: 220)
        .background(Color.gray.opacity(0.3))
}
