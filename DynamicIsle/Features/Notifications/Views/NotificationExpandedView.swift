import SwiftUI

struct NotificationExpandedView: View {
    let message: String
    @ObservedObject var viewModel: NotificationViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(notificationColor.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: viewModel.currentIcon)
                    .font(.system(size: 24))
                    .foregroundColor(notificationColor)
            }

            // Content
            VStack(spacing: 4) {
                Text(viewModel.currentTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            // Dismiss button
            Button(action: viewModel.dismissCurrent) {
                Text("Dismiss")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var notificationColor: Color {
        switch viewModel.currentType {
        case .info:
            return .blue
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .timer:
            return .purple
        case .calendar:
            return .blue
        }
    }
}

#Preview {
    NotificationExpandedView(
        message: "Focus Timer has finished",
        viewModel: NotificationViewModel()
    )
    .frame(width: 328, height: 156)
    .padding(16)
    .background(Color.black)
    .cornerRadius(24)
}
