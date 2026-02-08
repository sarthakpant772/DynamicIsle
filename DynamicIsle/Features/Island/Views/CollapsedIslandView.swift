import SwiftUI

/// Collapsed (compact) view of the Dynamic Island
struct CollapsedIslandView: View {
    @ObservedObject var viewModel: IslandViewModel

    var body: some View {
        HStack(spacing: 8) {
            switch viewModel.currentMode {
            case .nowPlaying:
                NowPlayingCollapsedView(viewModel: viewModel.nowPlayingViewModel)

            case .timer:
                TimerCollapsedView(viewModel: viewModel.timerViewModel)

            case .calendar:
                CalendarCollapsedView(viewModel: viewModel.calendarViewModel)

            case .notification(let message):
                NotificationCollapsedView(message: message)

            case .ai:
                AICollapsedView(viewModel: viewModel.aiViewModel)

            case .meeting:
                MeetingCollapsedView(viewModel: viewModel.meetingViewModel)

            case .clipboard:
                ClipboardCollapsedView(viewModel: viewModel.clipboardViewModel)

            case .focus:
                FocusCollapsedView(viewModel: viewModel.focusViewModel)

            case .idle:
                IdleCollapsedView()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// Default idle state view
struct IdleCollapsedView: View {
    @State private var dotScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 6) {
            // Subtle breathing animation dot
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 6, height: 6)
                .scaleEffect(dotScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        dotScale = 0.7
                    }
                }

            Text("Dynamic Isle")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview("Idle") {
    CollapsedIslandView(viewModel: IslandViewModel())
        .frame(width: 200, height: 36)
        .background(Color.black)
        .cornerRadius(18)
}
