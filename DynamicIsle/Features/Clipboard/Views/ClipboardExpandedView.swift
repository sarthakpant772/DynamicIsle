import SwiftUI

struct ClipboardExpandedView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(.orange)
                Text("Clipboard History")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if viewModel.hasItems {
                    Button(action: viewModel.clearHistory) {
                        Text("Clear")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if viewModel.hasItems {
                // Clipboard items list
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(viewModel.recentItems) { item in
                            ClipboardItemRow(item: item, viewModel: viewModel)
                        }
                    }
                }
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.3))

                    Text("No clipboard history")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))

                    Text("Copy something to get started")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Keyboard shortcut hint
            Text("Click to copy • ⌘V to paste")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    @ObservedObject var viewModel: ClipboardViewModel
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            // Type icon
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 28, height: 28)

                if item.type == .image, let image = item.image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                } else {
                    Image(systemName: item.icon)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Content preview
            VStack(alignment: .leading, spacing: 2) {
                Text(item.preview)
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(item.relativeTime)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            // Actions (show on hover)
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: { viewModel.copy(item: item) }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { viewModel.remove(item: item) }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isHovered ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            viewModel.copy(item: item)
        }
    }
}

#Preview {
    ClipboardExpandedView(viewModel: ClipboardViewModel())
        .frame(width: 328, height: 180)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
}
