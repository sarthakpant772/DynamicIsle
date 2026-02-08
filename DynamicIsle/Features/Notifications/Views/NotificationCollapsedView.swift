import SwiftUI

struct NotificationCollapsedView: View {
    let message: String
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 8) {
            // Bell icon with animation
            Image(systemName: "bell.fill")
                .font(.system(size: 12))
                .foregroundColor(.yellow)
                .rotationEffect(.degrees(isAnimating ? 15 : -15))
                .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear { isAnimating = true }

            // Message
            Text(message)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()
        }
    }
}

#Preview {
    NotificationCollapsedView(message: "Timer complete!")
        .frame(width: 176, height: 20)
        .padding()
        .background(Color.black)
}
