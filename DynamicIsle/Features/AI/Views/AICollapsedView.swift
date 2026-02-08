import SwiftUI

struct AICollapsedView: View {
    @ObservedObject var viewModel: AIViewModel

    var body: some View {
        HStack(spacing: 8) {
            // AI icon
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 22, height: 22)

                Image(systemName: "sparkles")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
            }

            if viewModel.isLoading {
                // Loading state
                HStack(spacing: 4) {
                    Text("Thinking")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)

                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 12, height: 12)
                }
            } else if !viewModel.response.isEmpty {
                // Has response
                Text(viewModel.response)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            } else {
                // Idle
                Text("Ask AI anything...")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Keyboard shortcut hint
            Text("⌘J")
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.1))
                .cornerRadius(3)
        }
    }
}

#Preview {
    AICollapsedView(viewModel: AIViewModel())
        .frame(width: 176, height: 20)
        .padding()
        .background(Color.black)
}
