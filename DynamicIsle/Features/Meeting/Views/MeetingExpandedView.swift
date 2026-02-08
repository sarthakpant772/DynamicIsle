import SwiftUI

struct MeetingExpandedView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @State private var countdown: String = ""
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.hasMeeting {
                meetingView
            } else {
                noMeetingView
            }
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Meeting View

    private var meetingView: some View {
        VStack(spacing: 12) {
            // Header with platform
            HStack {
                platformBadge

                Spacer()

                // Dismiss button
                Button(action: viewModel.dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Meeting title
            Text(viewModel.meetingTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Countdown or time
            if viewModel.isMeetingSoon || viewModel.isHappeningNow {
                countdownView
            } else {
                Text("Starts at \(viewModel.meetingTime)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Join button
            Button(action: viewModel.joinMeeting) {
                HStack(spacing: 8) {
                    Image(systemName: "video.fill")
                    Text(viewModel.isHappeningNow ? "Join Now" : "Join Meeting")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var platformBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.platformIcon)
                .font(.system(size: 10))

            Text(viewModel.platformName)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.white.opacity(0.7))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.15))
        .cornerRadius(6)
    }

    private var countdownView: some View {
        VStack(spacing: 4) {
            if viewModel.isHappeningNow {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)

                    Text("HAPPENING NOW")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                }
            } else {
                Text("Starting in")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))

                Text(countdown)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            }
        }
    }

    // MARK: - No Meeting View

    private var noMeetingView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.4))

            Text("No Upcoming Meetings")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            Text("You're all clear!")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Countdown Timer

    private func startCountdown() {
        updateCountdown()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateCountdown()
        }
    }

    private func updateCountdown() {
        guard let meeting = viewModel.meeting else {
            countdown = ""
            return
        }

        let timeUntil = meeting.startTime.timeIntervalSinceNow

        if timeUntil <= 0 {
            countdown = "0:00"
        } else if timeUntil < 3600 {
            let minutes = Int(timeUntil) / 60
            let seconds = Int(timeUntil) % 60
            countdown = String(format: "%d:%02d", minutes, seconds)
        } else {
            let hours = Int(timeUntil) / 3600
            let minutes = (Int(timeUntil) % 3600) / 60
            countdown = String(format: "%d:%02d:%02d", hours, minutes, 0)
        }
    }
}

#Preview {
    MeetingExpandedView(viewModel: MeetingViewModel())
        .frame(width: 328, height: 180)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
}
